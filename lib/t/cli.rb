require 'action_view'
require 'active_support/core_ext/array/grouping'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/numeric/time'
require 'csv'
# 'fastercsv' required on Ruby versions < 1.9
require 'fastercsv' unless Array.new.respond_to?(:to_csv)
require 'geokit'
require 'launchy'
require 'oauth'
require 'open-uri'
require 't/authorizable'
require 't/collectable'
require 't/core_ext/string'
require 't/delete'
require 't/list'
require 't/printable'
require 't/rcfile'
require 't/requestable'
require 't/search'
require 't/set'
require 't/stream'
require 't/version'
require 'thor'
require 'time'
require 'twitter'
require 'yaml'

module T
  class CLI < Thor
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper
    include T::Authorizable
    include T::Collectable
    include T::Printable
    include T::Requestable

    DEFAULT_NUM_RESULTS = 20
    MAX_SCREEN_NAME_SIZE = 20
    MAX_USERS_PER_REQUEST = 100

    check_unknown_options!

    option "host", :aliases => "-H", :type => :string, :default => DEFAULT_HOST, :desc => "Twitter API server"
    option "no-color", :aliases => "-N", :type => :boolean, :banner => "Disable colorization in output"
    option "no-ssl", :aliases => "-U", :type => :boolean, :default => false, :desc => "Disable SSL"
    option "profile", :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "accounts", "List accounts"
    def accounts
      @rcfile.path = options['profile'] if options['profile']
      @rcfile.profiles.each do |profile|
        say profile[0]
        profile[1].keys.each do |key|
          say "  #{key}#{@rcfile.active_profile[0] == profile[0] && @rcfile.active_profile[1] == key ? " (active)" : nil}"
        end
      end
    end

    desc "authorize", "Allows an application to request user authorization"
    method_option "consumer-key", :aliases => "-c", :required => true, :desc => "This can be found at https://dev.twitter.com/apps"
    method_option "consumer-secret", :aliases => "-s", :required => true, :desc => "This can be found at https://dev.twitter.com/apps"
    method_option "display-url", :aliases => "-d", :type => :boolean, :default => false, :desc => "Display the authorization URL instead of attempting to open it."
    method_option "prompt", :aliases => "-p", :type => :boolean, :default => true
    def authorize
      request_token = consumer.get_request_token
      url = generate_authorize_url(request_token)
      if options['prompt']
        say "In a moment, you will be directed to the Twitter app authorization page."
        say "Perform the following steps to complete the authorization process:"
        say "  1. Sign in to Twitter"
        say "  2. Press \"Authorize app\""
        say "  3. Copy or memorize the supplied PIN"
        say "  4. Return to the terminal to enter the PIN"
        say
        ask "Press [Enter] to open the Twitter app authorization page."
        say
      end
      Launchy.open(url, :dry_run => options['display-url'])
      pin = ask "Paste in the supplied PIN:"
      access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
      oauth_response = access_token.get('/1/account/verify_credentials.json')
      screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first
      @rcfile.path = options['profile'] if options['profile']
      @rcfile[screen_name] = {
        options['consumer-key'] => {
          'username' => screen_name,
          'consumer_key' => options['consumer-key'],
          'consumer_secret' => options['consumer-secret'],
          'token' => access_token.token,
          'secret' => access_token.secret,
        }
      }
      @rcfile.active_profile = {'username' => screen_name, 'consumer_key' => options['consumer-key']}
      say "Authorization successful."
    end

    desc "block USER [USER...]", "Block users."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def block(user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users = users.threaded_map do |user|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.block(user)
        end
      end
      number = users.length
      say "@#{@rcfile.active_profile[0]} blocked #{number} #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} delete block #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to unblock."
    end

    desc "direct_messages", "Returns the #{DEFAULT_NUM_RESULTS} most recent Direct Messages sent to you."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def direct_messages
      count = options['number'] || DEFAULT_NUM_RESULTS
      direct_messages = collect_with_count(count) do |opts|
        client.direct_messages(opts)
      end
      direct_messages.reverse! if options['reverse']
      if options['csv']
        say ["ID", "Posted at", "Screen name", "Text"].to_csv unless direct_messages.empty?
        direct_messages.each do |direct_message|
          say [direct_message.id, direct_message.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), direct_message.sender.screen_name, direct_message.text].to_csv
        end
      elsif options['long']
        array = direct_messages.map do |direct_message|
          created_at = direct_message.created_at > 6.months.ago ? direct_message.created_at.strftime("%b %e %H:%M") : direct_message.created_at.strftime("%b %e  %Y")
          [direct_message.id, created_at, "@#{direct_message.sender.screen_name}", HTMLEntities.new.decode(direct_message.text).gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Posted at", "Screen name", "Text"]
          array.unshift(headings) unless direct_messages.empty?
          print_table(array, :truncate => true)
        else
          print_table(array)
        end
      else
        direct_messages.each do |direct_message|
          say "#{direct_message.sender.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(direct_message.created_at)} ago)"
        end
      end
    end
    map %w(directmessages dms) => :direct_messages

    desc "direct_messages_sent", "Returns the #{DEFAULT_NUM_RESULTS} most recent Direct Messages sent to you."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def direct_messages_sent
      count = options['number'] || DEFAULT_NUM_RESULTS
      direct_messages = collect_with_count(count) do |opts|
        client.direct_messages_sent(opts)
      end
      direct_messages.reverse! if options['reverse']
      if options['csv']
        say ["ID", "Posted at", "Screen name", "Text"].to_csv unless direct_messages.empty?
        direct_messages.each do |direct_message|
          say [direct_message.id, direct_message.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), direct_message.recipient.screen_name, direct_message.text].to_csv
        end
      elsif options['long']
        array = direct_messages.map do |direct_message|
          created_at = direct_message.created_at > 6.months.ago ? direct_message.created_at.strftime("%b %e %H:%M") : direct_message.created_at.strftime("%b %e  %Y")
          [direct_message.id, created_at, "@#{direct_message.recipient.screen_name}", HTMLEntities.new.decode(direct_message.text).gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Posted at", "Screen name", "Text"]
          array.unshift(headings) unless direct_messages.empty?
          print_table(array, :truncate => true)
        else
          print_table(array)
        end
      else
        direct_messages.each do |direct_message|
          say "#{direct_message.recipient.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(direct_message.created_at)} ago)"
        end
      end
    end
    map %w(directmessagessent sent_messages sentmessages sms) => :direct_messages_sent

    desc "disciples [USER]", "Returns the list of people who follow you but you don't follow back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def disciples(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(user, :cursor => cursor)
      end
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(user, :cursor => cursor)
      end
      disciple_ids = (follower_ids - following_ids)
      users = disciple_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |disciple_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(disciple_id_group)
        end
      end.flatten
      print_users(users)
    end

    desc "dm USER MESSAGE", "Sends that person a Direct Message."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    def dm(user, message)
      user = if options['id']
        user.to_i
      else
        user.strip_ats
      end
      direct_message = client.direct_message_create(user, message)
      say "Direct Message sent from @#{@rcfile.active_profile[0]} to @#{direct_message.recipient.screen_name} (#{time_ago_in_words(direct_message.created_at)} ago)."
    end
    map %w(d m) => :dm

    desc "does_contain [USER/]LIST USER", "Find out whether a list contains a user."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    def does_contain(list, user=nil)
      owner, list = list.split('/')
      if list.nil?
        list = owner
        owner = @rcfile.active_profile[0]
      else
        owner = if options['id']
          client.user(owner.to_i).screen_name
        else
          owner.strip_ats
        end
      end
      if user.nil?
        user = @rcfile.active_profile[0]
      else
        user = if options['id']
          user = client.user(user.to_i).screen_name
        else
          user.strip_ats
        end
      end
      if client.list_member?(owner, list, user)
        say "Yes, @#{owner}/#{list} contains @#{user}."
      else
        say "No, @#{owner}/#{list} does not contain @#{user}."
        exit 1
      end
    end
    map %w(dc doescontain) => :does_contain

    desc "does_follow USER [USER]", "Find out whether one user follows another."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    def does_follow(user1, user2=nil)
      user1 = if options['id']
        client.user(user1.to_i).screen_name
      else
        user1.strip_ats
      end
      if user2.nil?
        user2 = @rcfile.active_profile[0]
      else
        user2 = if options['id']
          client.user(user2.to_i).screen_name
        else
          user2.strip_ats
        end
      end
      if client.friendship?(user1, user2)
        say "Yes, @#{user1} follows @#{user2}."
      else
        say "No, @#{user1} does not follow @#{user2}."
        exit 1
      end
    end
    map %w(df doesfollow) => :does_follow

    desc "favorite STATUS_ID [STATUS_ID...]", "Marks Tweets as favorites."
    def favorite(status_id, *status_ids)
      status_ids.unshift(status_id)
      status_ids.map!(&:strip_commas)
      favorites = status_ids.threaded_map do |status_id|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.favorite(status_id.to_i)
        end
      end
      number = favorites.length
      say "@#{@rcfile.active_profile[0]} favorited #{number} #{number == 1 ? 'tweet' : 'tweets'}."
      say
      say "Run `#{File.basename($0)} delete favorite #{status_ids.join(' ')}` to unfavorite."
    end
    map %w(fave favourite) => :favorite

    desc "favorites [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets you favorited."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def favorites(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = collect_with_count(count) do |opts|
        client.favorites(user, opts)
      end
      print_statuses(statuses)
    end
    map %w(faves favourites) => :favorites

    desc "follow USER [USER...]", "Allows you to start following users."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def follow(user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users = users.threaded_map do |user|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.follow(user)
        end
      end
      number = users.length
      say "@#{@rcfile.active_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} unfollow #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to stop."
    end

    desc "followings [USER]", "Returns a list of the people you follow on Twitter."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def followings(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(user, :cursor => cursor)
      end
      users = following_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |following_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(following_id_group)
        end
      end.flatten
      print_users(users)
    end

    desc "followers [USER]", "Returns a list of the people who follow you on Twitter."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def followers(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(user, :cursor => cursor)
      end
      users = follower_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |follower_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(follower_id_group)
        end
      end.flatten
      print_users(users)
    end

    desc "friends [USER]", "Returns the list of people who you follow and follow you back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def friends(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(user, :cursor => cursor)
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(user, :cursor => cursor)
      end
      friend_ids = (following_ids & follower_ids)
      users = friend_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |friend_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(friend_id_group)
        end
      end.flatten
      print_users(users)
    end

    desc "leaders [USER]", "Returns the list of people who you follow but don't follow you back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def leaders(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(user, :cursor => cursor)
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(user, :cursor => cursor)
      end
      leader_ids = (following_ids - follower_ids)
      users = leader_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |leader_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(leader_id_group)
        end
      end.flatten
      print_users(users)
    end

    desc "lists [USER]", "Returns the lists created by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "members", :aliases => "-m", :type => :boolean, :default => false, :desc => "Sort by number of members."
    method_option "mode", :aliases => "-o", :type => :boolean, :default => false, :desc => "Sort by mode."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter list was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "subscribers", :aliases => "-s", :type => :boolean, :default => false, :desc => "Sort by number of subscribers."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def lists(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      lists = collect_with_cursor do |cursor|
        client.lists(user, :cursor => cursor)
      end
      print_lists(lists)
    end

    desc "mentions", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets mentioning you."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def mentions
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = collect_with_count(count) do |opts|
        client.mentions(opts)
      end
      print_statuses(statuses)
    end
    map %w(replies) => :mentions

    desc "open USER", "Opens that user's profile in a web browser."
    method_option "display-url", :aliases => "-d", :type => :boolean, :default => false, :desc => "Display the requested URL instead of attempting to open it."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "status", :aliases => "-s", :type => :boolean, :default => false, :desc => "Specify input as a Twitter status ID instead of a screen name."
    def open(user)
      if options['id']
        user = client.user(user.to_i)
        Launchy.open("https://twitter.com/#{user.screen_name}", :dry_run => options['display-url'])
      elsif options['status']
        status = client.status(user.to_i, :include_my_retweet => false)
        Launchy.open("https://twitter.com/#{status.user.screen_name}/status/#{status.id}", :dry_run => options['display-url'])
      else
        Launchy.open("https://twitter.com/#{user.strip_ats}", :dry_run => options['display-url'])
      end
    end

    desc "reply STATUS_ID MESSAGE", "Post your Tweet as a reply directed at another person."
    method_option "all", :aliases => "-a", :type => "boolean", :default => false, :desc => "Reply to all users mentioned in the Tweet."
    method_option "location", :aliases => "-l", :type => :boolean, :default => false
    def reply(status_id, message)
      status_id = status_id.strip_commas
      status = client.status(status_id.to_i, :include_my_retweet => false)
      users = Array(status.user.screen_name)
      if options['all']
        # twitter-text requires $KCODE to be set to UTF8 on Ruby versions < 1.8
        major, minor, patch = RUBY_VERSION.split('.')
        $KCODE='u' if major.to_i == 1 && minor.to_i < 9
        require 'twitter-text'
        users += Twitter::Extractor.extract_mentioned_screen_names(status.text)
        users.uniq!
      end
      users.map!(&:prepend_at)
      opts = {:in_reply_to_status_id => status.id, :trim_user => true}
      opts.merge!(:lat => location.lat, :long => location.lng) if options['location']
      reply = client.update("#{users.join(' ')} #{message}", opts)
      say "Reply created by @#{@rcfile.active_profile[0]} to #{users.join(' ')} (#{time_ago_in_words(reply.created_at)} ago)."
      say
      say "Run `#{File.basename($0)} delete status #{reply.id}` to delete."
    end

    desc "report_spam USER [USER...]", "Report users for spam."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def report_spam(user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users = users.threaded_map do |user|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.report_spam(user)
        end
      end
      number = users.length
      say "@#{@rcfile.active_profile[0]} reported #{number} #{number == 1 ? 'user' : 'users'}."
    end
    map %w(report reportspam spam) => :report_spam

    desc "retweet STATUS_ID [STATUS_ID...]", "Sends Tweets to your followers."
    def retweet(status_id, *status_ids)
      status_ids.unshift(status_id)
      status_ids.map!(&:strip_commas)
      retweets = status_ids.threaded_map do |status_id|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.retweet(status_id.to_i, :trim_user => true)
        end
      end
      number = retweets.length
      say "@#{@rcfile.active_profile[0]} retweeted #{number} #{number == 1 ? 'tweet' : 'tweets'}."
      say
      say "Run `#{File.basename($0)} delete status #{status_ids.join(' ')}` to undo."
    end
    map %w(rt) => :retweet

    desc "retweets [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Retweets by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def retweets(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = collect_with_count(count) do |opts|
        client.retweeted_by(user, opts)
      end
      print_statuses(statuses)
    end
    map %w(rts) => :retweets

    desc "ruler", "Prints a 140-character ruler"
    def ruler
      say "----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|"
    end

    desc "status STATUS_ID", "Retrieves detailed information about a Tweet."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def status(status_id)
      status_id = status_id.strip_commas
      status = client.status(status_id.to_i, :include_my_retweet => false)
      if status.geo
        geoloc = Geokit::Geocoders::MultiGeocoder.reverse_geocode(status.geo.coordinates)
        location = if geoloc.city && geoloc.state && geoloc.country
          [geoloc.city, geoloc.state, geoloc.country].join(", ")
        elsif geoloc.state && geoloc.country
          [geoloc.state, geoloc.country].join(", ")
        else
          geoloc.country
        end
      else
        location = nil
      end
      if options['csv']
        say ["ID", "Text", "Screen name", "Posted at", "Location", "Retweets", "Source", "URL"].to_csv
        say [status.id, HTMLEntities.new.decode(status.text), status.user.screen_name, status.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), location, status.retweet_count, strip_tags(status.source), "https://twitter.com/#{status.user.screen_name}/status/#{status.id}"].to_csv
      else
        array = []
        array << ["ID", status.id.to_s]
        array << ["Text", HTMLEntities.new.decode(status.text).gsub(/\n+/, ' ')]
        array << ["Screen name", "@#{status.user.screen_name}"]
        posted_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
        array << ["Posted at", posted_at]
        array << ["Location", location] unless location.nil?
        array << ["Retweets", number_with_delimiter(status.retweet_count)]
        array << ["Source", strip_tags(status.source)]
        array << ["URL", "https://twitter.com/#{status.user.screen_name}/status/#{status.id}"]
        print_table(array)
      end
    end

    desc "suggest [USER]", "Returns a listing of Twitter users' accounts you might enjoy following."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def suggest(user=nil)
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      limit = options['number'] || DEFAULT_NUM_RESULTS
      users = client.recommendations(user, :limit => limit)
      print_users(users)
    end

    desc "timeline [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets posted by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def timeline(user=nil)
      count = options['number'] || DEFAULT_NUM_RESULTS
      if user
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
        statuses = collect_with_count(count) do |opts|
          client.user_timeline(user, opts)
        end
      else
        statuses = collect_with_count(count) do |opts|
          client.home_timeline(opts)
        end
      end
      print_statuses(statuses)
    end
    map %w(tl) => :timeline

    desc "trends [WOEID]", "Returns the top 10 trending topics."
    method_option "exclude-hashtags", :aliases => "-x", :type => "boolean", :default => false, :desc => "Remove all hashtags from the trends list."
    def trends(woe_id=1)
      opts = {}
      opts.merge!(:exclude => "hashtags") if options['exclude-hashtags']
      trends = client.trends(woe_id, opts)
      if STDOUT.tty?
        print_in_columns(trends.map(&:name))
      else
        trends.each do |trend|
          say trend.name
        end
      end
    end

    desc "trends_locations", "Returns the locations for which Twitter has trending topic information."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def trend_locations
      places = client.trend_locations
      places = places.sort_by{|places| places.name.downcase} unless options['unsorted']
      places.reverse! if options['reverse']
      if options['csv']
        say ["WOEID", "Parent ID", "Type", "Name", "Country"].to_csv unless places.empty?
        places.each do |place|
          say [place.woeid, place.parent_id, place.place_type, place.name, place.country].to_csv
        end
      elsif options['long']
        array = places.map do |place|
          [place.woeid, place.parent_id, place.place_type, place.name, place.country]
        end
        if STDOUT.tty?
          headings = ["WOEID", "Parent ID", "Type", "Name", "Country"]
          array.unshift(headings) unless places.empty?
          print_table(array, :truncate => true)
        else
          print_table(array)
        end
      else
        if STDOUT.tty?
          print_in_columns(places.map(&:name))
        else
          places.each do |place|
            say place.name
          end
        end
      end
    end
    map %w(locations trendlocations) => :trend_locations

    desc "unfollow USER [USER...]", "Allows you to stop following users."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def unfollow(user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users = users.threaded_map do |user|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.unfollow(user)
        end
      end
      number = users.length
      say "@#{@rcfile.active_profile[0]} is no longer following #{number} #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} follow #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to follow again."
    end

    desc "update MESSAGE", "Post a Tweet."
    method_option "location", :aliases => "-l", :type => :boolean, :default => false
    def update(message)
      opts = {:trim_user => true}
      opts.merge!(:lat => location.lat, :long => location.lng) if options['location']
      status = client.update(message, opts)
      say "Tweet created by @#{@rcfile.active_profile[0]} (#{time_ago_in_words(status.created_at)} ago)."
      say
      say "Run `#{File.basename($0)} delete status #{status.id}` to delete."
    end
    map %w(post tweet) => :update

    desc "users USER [USER...]", "Returns a list of users you specify."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "favorites", :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by number of favorites."
    method_option "followers", :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by number of followers."
    method_option "friends", :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by number of friends."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    method_option "listed", :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "posted", :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter account was posted."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "tweets", :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by number of Tweets."
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def users(user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users = client.users(users)
      print_users(users)
    end
    map %w(stats) => :users

    desc "version", "Show version."
    def version
      say T::Version
    end
    map %w(-v --version) => :version

    desc "whois USER", "Retrieves profile information for the user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    def whois(user)
      user = if options['id']
        user.to_i
      else
        user.strip_ats
      end
      user = client.user(user)
      if options['csv']
        say ["ID", "Verified", "Name", "Screen name", "Bio", "Location", "Following", "Last update", "Lasted updated at", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "URL"].to_csv
        say [user.id, user.verified?, user.name, user.screen_name, user.description, user.location, user.following?, HTMLEntities.new.decode(user.status.text), user.status.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), user.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), user.statuses_count, user.favourites_count, user.listed_count, user.friends_count, user.followers_count, user.url].to_csv
      else
        array = []
        name_label = user.verified ? "Name (Verified)" : "Name"
        array << ["ID", user.id.to_s]
        array << [name_label, user.name] unless user.name.nil?
        array << ["Bio", user.description.gsub(/\n+/, ' ')] unless user.description.nil?
        array << ["Location", user.location] unless user.location.nil?
        status = user.following ? "Following" : "Not following"
        array << ["Status", status]
        array << ["Last update", "#{HTMLEntities.new.decode(user.status.text).gsub(/\n+/, ' ')} (#{time_ago_in_words(user.status.created_at)} ago)"] unless user.status.nil?
        created_at = user.created_at > 6.months.ago ? user.created_at.strftime("%b %e %H:%M") : user.created_at.strftime("%b %e  %Y")
        array << ["Since", created_at]
        array << ["Tweets", number_with_delimiter(user.statuses_count)]
        array << ["Favorites", number_with_delimiter(user.favourites_count)]
        array << ["Listed", number_with_delimiter(user.listed_count)]
        array << ["Following", number_with_delimiter(user.friends_count)]
        array << ["Followers", number_with_delimiter(user.followers_count)]
        array << ["URL", user.url] unless user.url.nil?
        print_table(array)
      end
    end
    map %w(user) => :whois

    desc "delete SUBCOMMAND ...ARGS", "Delete Tweets, Direct Messages, etc."
    subcommand 'delete', T::Delete

    desc "list SUBCOMMAND ...ARGS", "Do various things with lists."
    subcommand 'list', T::List

    desc "search SUBCOMMAND ...ARGS", "Search through Tweets."
    subcommand 'search', T::Search

    desc "set SUBCOMMAND ...ARGS", "Change various account settings."
    subcommand 'set', T::Set

    desc "stream SUBCOMMAND ...ARGS", "Commands for streaming Tweets."
    subcommand 'stream', T::Stream

  private

    def location
      return @location if @location
      ip_address = Kernel::open("http://checkip.dyndns.org/") do |body|
        /(?:\d{1,3}\.){3}\d{1,3}/.match(body.read)[0]
      end
      @location = Geokit::Geocoders::MultiGeocoder.geocode(ip_address)
    end

  end
end
