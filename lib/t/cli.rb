require 'action_view'
require 'active_support/core_ext/array/grouping'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/numeric/time'
require 'highline'
require 'launchy'
require 'oauth'
require 't/collectable'
require 't/core_ext/string'
require 't/delete'
require 't/list'
require 't/rcfile'
require 't/search'
require 't/set'
require 't/version'
require 'thor'
require 'time'
require 'twitter'
require 'yaml'

module T
  class CLI < Thor
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
    include T::Collectable

    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'
    DEFAULT_NUM_RESULTS = 20
    MAX_SCREEN_NAME_SIZE = 20
    MAX_USERS_PER_REQUEST = 100

    check_unknown_options!

    option :host, :aliases => "-H", :type => :string, :default => DEFAULT_HOST, :desc => "Twitter API server"
    option :no_ssl, :aliases => "-U", :type => :boolean, :default => false, :desc => "Disable SSL"
    option :profile, :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

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
          say "  #{key}#{@rcfile.default_profile[0] == profile[0] && @rcfile.default_profile[1] == key ? " (default)" : nil}"
        end
      end
    end

    desc "authorize", "Allows an application to request user authorization"
    method_option :consumer_key, :aliases => "-c", :required => true
    method_option :consumer_secret, :aliases => "-s", :required => true
    method_option :prompt, :aliases => "-p", :type => :boolean, :default => true
    method_option :dry_run, :type => :boolean
    def authorize
      request_token = consumer.get_request_token
      url = generate_authorize_url(request_token)
      if options['prompt']
        say "In a moment, your web browser will open to the Twitter app authorization page."
        say "Perform the following steps to complete the authorization process:"
        say "  1. Sign in to Twitter"
        say "  2. Press \"Authorize app\""
        say "  3. Copy or memorize the supplied PIN"
        say "  4. Return to the terminal to enter the PIN"
        say
        ask "Press [Enter] to open the Twitter app authorization page."
        say
      end
      Launchy.open(url, :dry_run => options.fetch('dry_run', false))
      pin = ask "Paste in the supplied PIN:"
      access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
      oauth_response = access_token.get('/1/account/verify_credentials.json')
      screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first
      @rcfile.path = options['profile'] if options['profile']
      @rcfile[screen_name] = {
        options['consumer_key'] => {
          'username' => screen_name,
          'consumer_key' => options['consumer_key'],
          'consumer_secret' => options['consumer_secret'],
          'token' => access_token.token,
          'secret' => access_token.secret,
        }
      }
      @rcfile.default_profile = {'username' => screen_name, 'consumer_key' => options['consumer_key']}
      say "Authorization successful."
    end

    desc "block SCREEN_NAME [SCREEN_NAME...]", "Block users."
    def block(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.threaded_each do |screen_name|
        screen_name.strip_at
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.block(screen_name, :include_entities => false)
        end
      end
      say "@#{@rcfile.default_profile[0]} blocked @#{screen_names.join(' ')}."
      say
      say "Run `#{File.basename($0)} delete block #{screen_names.join(' ')}` to unblock."
    end

    desc "direct_messages", "Returns the #{DEFAULT_NUM_RESULTS} most recent Direct Messages sent to you."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def direct_messages
      count = options['number'] || DEFAULT_NUM_RESULTS
      direct_messages = client.direct_messages(:count => count, :include_entities => false)
      direct_messages.reverse! if options['reverse']
      if options['long']
        array = direct_messages.map do |direct_message|
          created_at = direct_message.created_at > 6.months.ago ? direct_message.created_at.strftime("%b %e %H:%M") : direct_message.created_at.strftime("%b %e  %Y")
          [direct_message.id.to_s, created_at, direct_message.sender.screen_name, direct_message.text.gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Created at", "Screen name", "Text"]
          array.unshift(headings)
        end
        print_table(array)
      else
        direct_messages.each do |direct_message|
          say "#{direct_message.sender.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(direct_message.created_at)} ago)"
        end
      end
    end
    map %w(dms) => :direct_messages

    desc "direct_messages_sent", "Returns the #{DEFAULT_NUM_RESULTS} most recent Direct Messages sent to you."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def direct_messages_sent
      count = options['number'] || DEFAULT_NUM_RESULTS
      direct_messages = client.direct_messages_sent(:count => count, :include_entities => false)
      direct_messages.reverse! if options['reverse']
      if options['long']
        array = direct_messages.map do |direct_message|
          created_at = direct_message.created_at > 6.months.ago ? direct_message.created_at.strftime("%b %e %H:%M") : direct_message.created_at.strftime("%b %e  %Y")
          [direct_message.id.to_s, created_at, direct_message.recipient.screen_name, direct_message.text.gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Created at", "Screen name", "Text"]
          array.unshift(headings)
        end
        print_table(array)
      else
        direct_messages.each do |direct_message|
          say "#{direct_message.recipient.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(direct_message.created_at)} ago)"
        end
      end
    end
    map %w(sent_messages sms) => :direct_messages_sent

    desc "dm SCREEN_NAME MESSAGE", "Sends that person a Direct Message."
    def dm(screen_name, message)
      screen_name = screen_name.strip_at
      direct_message = client.direct_message_create(screen_name, message, :include_entities => false)
      say "Direct Message sent from @#{@rcfile.default_profile[0]} to @#{direct_message.recipient.screen_name} (#{time_ago_in_words(direct_message.created_at)} ago)."
    end
    map %w(d m) => :dm

    desc "favorite STATUS_ID [STATUS_ID...]", "Marks Tweets as favorites."
    def favorite(status_id, *status_ids)
      status_ids.unshift(status_id)
      favorites = status_ids.threaded_map do |status_id|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.favorite(status_id, :include_entities => false)
        end
      end
      favorites.each do |status|
        say "@#{@rcfile.default_profile[0]} favorited @#{status.user.screen_name}'s status: \"#{status.text.gsub(/\n+/, ' ')}\""
      end
      say
      say "Run `#{File.basename($0)} delete favorite #{status_ids.join(' ')}` to unfavorite."
    end
    map %w(fave) => :favorite

    desc "favorites", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets you favorited."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def favorites
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.favorites(:count => count, :include_entities => false)
      print_status_list(statuses)
    end
    map %w(faves) => :favorites

    desc "follow SCREEN_NAME [SCREEN_NAME...]", "Allows you to start following users."
    def follow(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.threaded_each do |screen_name|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.follow(screen_name, :include_entities => false)
        end
      end
      number = screen_names.length
      say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} unfollow users #{screen_names.join(' ')}` to stop."
    end

    desc "followings", "Returns a list of the people you follow on Twitter."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def followings
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(:cursor => cursor)
      end
      users = following_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |following_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(following_id_group, :include_entities => false)
        end
      end.flatten
      print_user_list(users)
    end

    desc "followers", "Returns a list of the people who follow you on Twitter."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def followers
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(:cursor => cursor)
      end
      users = follower_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |follower_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(follower_id_group, :include_entities => false)
        end
      end.flatten
      print_user_list(users)
    end

    desc "friends", "Returns the list of people who you follow and follow you back."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def friends
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(:cursor => cursor)
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(:cursor => cursor)
      end
      friend_ids = (following_ids & follower_ids)
      users = friend_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |friend_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(friend_id_group, :include_entities => false)
        end
      end.flatten
      print_user_list(users)
    end

    desc "leaders", "Returns the list of people who you follow but don't follow you back."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def leaders
      following_ids = collect_with_cursor do |cursor|
        client.friend_ids(:cursor => cursor)
      end
      follower_ids = collect_with_cursor do |cursor|
        client.follower_ids(:cursor => cursor)
      end
      leader_ids = (following_ids - follower_ids)
      users = leader_ids.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_map do |leader_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.users(leader_id_group, :include_entities => false)
        end
      end.flatten
      print_user_list(users)
    end

    desc "members [SCREEN_NAME] LIST_NAME", "Returns the members of a Twitter list."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def members(*args)
      list = args.pop
      owner = args.pop || @rcfile.default_profile[0]
      users = collect_with_cursor do |cursor|
        client.list_members(owner, list, :cursor => cursor, :include_entities => false, :skip_status => true)
      end
      print_user_list(users)
    end

    desc "mentions", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets mentioning you."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def mentions
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.mentions(:count => count, :include_entities => false)
      print_status_list(statuses)
    end
    map %w(replies) => :mentions

    desc "open SCREEN_NAME", "Opens that user's profile in a web browser."
    method_option :dry_run, :type => :boolean
    def open(screen_name)
      screen_name = screen_name.strip_at
      Launchy.open("https://twitter.com/#{screen_name}", :dry_run => options.fetch('dry_run', false))
    end

    desc "reply STATUS_ID MESSAGE", "Post your Tweet as a reply directed at another person."
    method_option :location, :aliases => "-l", :type => :boolean, :default => false
    def reply(status_id, message)
      status = client.status(status_id, :include_entities => false, :include_my_retweet => false, :trim_user => true)
      opts = {:in_reply_to_status_id => status.id, :include_entities => false, :trim_user => true}
      opts.merge!(:lat => location.lat, :long => location.lng) if options['location']
      reply = client.update("@#{status.user.screen_name} #{message}", opts)
      say "Reply created by @#{@rcfile.default_profile[0]} to @#{status.user.screen_name} (#{time_ago_in_words(reply.created_at)} ago)."
      say
      say "Run `#{File.basename($0)} delete status #{reply.id}` to delete."
    end

    desc "report_spam SCREEN_NAME [SCREEN_NAME...]", "Report users for spam."
    def report_spam(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.threaded_each do |screen_name|
        screen_name.strip_at
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.report_spam(screen_name, :include_entities => false)
        end
      end
      say "@#{@rcfile.default_profile[0]} reported @#{screen_names.join(' ')}."
    end
    map %w(report spam) => :report_spam

    desc "retweet STATUS_ID [STATUS_ID...]", "Sends Tweets to your followers."
    def retweet(status_id, *status_ids)
      status_ids.unshift(status_id)
      retweets = status_ids.threaded_map do |status_id|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.retweet(status_id, :include_entities => false, :trim_user => true)
        end
      end
      retweets.each do |status|
        say "@#{@rcfile.default_profile[0]} retweeted @#{status.user.screen_name}'s status: \"#{status.text.gsub(/\n+/, ' ')}\""
      end
      say
      say "Run `#{File.basename($0)} delete status #{status_ids.join(' ')}` to undo."
    end
    map %w(rt) => :retweet

    desc "retweets [SCREEN_NAME]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Retweets by a user."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def retweets(screen_name=nil)
      screen_name = screen_name.strip_at if screen_name
      count = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.retweeted_by(screen_name, :count => count, :include_entities => false)
      print_status_list(statuses)
    end
    map %w(rts) => :retweets

    desc "status MESSAGE", "Post a Tweet."
    method_option :location, :aliases => "-l", :type => :boolean, :default => false
    def status(message)
      opts = {:include_entities => false, :trim_user => true}
      opts.merge!(:lat => location.lat, :long => location.lng) if options['location']
      status = client.update(message, opts)
      say "Tweet created by @#{@rcfile.default_profile[0]} (#{time_ago_in_words(status.created_at)} ago)."
      say
      say "Run `#{File.basename($0)} delete status #{status.id}` to delete."
    end
    map %w(post tweet update) => :status

    desc "suggest", "This command returns a listing of Twitter users' accounts we think you might enjoy following."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def suggest
      limit = options['number'] || DEFAULT_NUM_RESULTS
      users = client.recommendations(:limit => limit, :include_entities => false)
      print_user_list(users)
    end

    desc "timeline [SCREEN_NAME]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets posted by a user."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def timeline(screen_name=nil)
      count = options['number'] || DEFAULT_NUM_RESULTS
      if screen_name
        screen_name = screen_name.strip_at
        statuses = client.user_timeline(screen_name, :count => count, :include_entities => false)
      else
        statuses = client.home_timeline(:count => count, :include_entities => false)
      end
      print_status_list(statuses)
    end
    map %w(tl) => :timeline

    desc "unfollow SCREEN_NAME [SCREEN_NAME...]", "Allows you to stop following users."
    def unfollow(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.threaded_each do |screen_name|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.unfollow(screen_name, :include_entities => false)
        end
      end
      number = screen_names.length
      say "@#{@rcfile.default_profile[0]} is no longer following #{number} #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} follow users #{screen_names.join(' ')}` to follow again."
    end

    desc "users SCREEN_NAME [SCREEN_NAME...]", "Returns a list of users you specify."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def users(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      users = client.users(screen_names, :include_entities => false)
      print_user_list(users)
    end
    map %w(stats) => :users

    desc "version", "Show version."
    def version
      say T::Version
    end
    map %w(-v --version) => :version

    desc "whois SCREEN_NAME", "Retrieves profile information for the user."
    def whois(screen_name)
      screen_name = screen_name.strip_at
      user = client.user(screen_name, :include_entities => false)
      say "id: ##{number_with_delimiter(user.id)}"
      say "#{user.name}, since #{user.created_at.strftime("%b %Y")}."
      say "bio: #{user.description}"
      say "location: #{user.location}"
      say "web: #{user.url}"
    end

    desc "delete SUBCOMMAND ...ARGS", "Delete Tweets, Direct Messages, etc."
    method_option :force, :aliases => "-f", :type => :boolean, :default => false
    subcommand 'delete', T::Delete

    desc "list SUBCOMMAND ...ARGS", "Do various things with lists."
    subcommand 'list', T::List

    desc "search SUBCOMMAND ...ARGS", "Search through Tweets."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    subcommand 'search', T::Search

    desc "set SUBCOMMAND ...ARGS", "Change various account settings."
    subcommand 'set', T::Set

  private

    def base_url
      "#{protocol}://#{host}"
    end

    def client
      return @client if @client
      @rcfile.path = options['profile'] if options['profile']
      @client = Twitter::Client.new(
        :endpoint => base_url,
        :consumer_key => @rcfile.default_consumer_key,
        :consumer_secret => @rcfile.default_consumer_secret,
        :oauth_token => @rcfile.default_token,
        :oauth_token_secret  => @rcfile.default_secret
      )
    end

    def consumer
      OAuth::Consumer.new(
        options['consumer_key'],
        options['consumer_secret'],
        :site => base_url
      )
    end

    def generate_authorize_url(request_token)
      request = consumer.create_signed_request(:get, consumer.authorize_path, request_token, pin_auth_parameters)
      params = request['Authorization'].sub(/^OAuth\s+/, '').split(/,\s+/).map do |param|
        key, value = param.split('=')
        value =~ /"(.*?)"/
        "#{key}=#{CGI::escape($1)}"
      end.join('&')
      "#{base_url}#{request.path}?#{params}"
    end

    def host
      options['host'] || DEFAULT_HOST
    end

    def location
      return @location if @location
      require 'geokit'
      require 'open-uri'
      ip_address = Kernel::open("http://checkip.dyndns.org/") do |body|
        /(?:\d{1,3}\.){3}\d{1,3}/.match(body.read)[0]
      end
      @location = Geokit::Geocoders::MultiGeocoder.geocode(ip_address)
    end

    def pin_auth_parameters
      {:oauth_callback => 'oob'}
    end

    def print_in_columns(array)
      cols = HighLine::SystemExtensions.terminal_size[0]
      width = (array.map{|el| el.to_s.size}.max || 0) + 2
      array.each_with_index do |value, index|
        puts if (((index) % (cols / width))).zero? && !index.zero?
        printf("%-#{width}s", value)
      end
      puts
    end

    def print_status_list(statuses)
      statuses.reverse! if options['reverse']
      if options['long']
        array = statuses.map do |status|
          created_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
          [status.id.to_s, created_at, status.user.screen_name, status.text.gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Created at", "Screen name", "Text"]
          array.unshift(headings)
        end
        print_table(array)
      else
        statuses.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
    end

    def print_user_list(users)
      users = users.sort_by{|user| user.screen_name.downcase} unless options['unsorted']
      if options['created']
        users = users.sort_by{|user| user.created_at}
      elsif options['favorites']
        users = users.sort_by{|user| user.favourites_count}
      elsif options['followers']
        users = users.sort_by{|user| user.followers_count}
      elsif options['friends']
        users = users.sort_by{|user| user.friends_count}
      elsif options['listed']
        users = users.sort_by{|user| user.listed_count}
      elsif options['tweets']
        users = users.sort_by{|user| user.statuses_count}
      end
      users.reverse! if options['reverse']
      if options['long']
        array = users.map do |user|
          created_at = user.created_at > 6.months.ago ? user.created_at.strftime("%b %e %H:%M") : user.created_at.strftime("%b %e  %Y")
          [user.id, created_at, user.statuses_count, user.friends_count, user.followers_count, user.favourites_count, user.listed_count, user.screen_name, user.name]
        end
        if STDOUT.tty?
          headings = ["ID", "Created at", "Tweets", "Following", "Followers", "Favorites", "Listed", "Screen name", "Name"]
          array.unshift(headings)
        end
        print_table(array)
      else
        if STDOUT.tty?
          print_in_columns(users.map(&:screen_name))
        else
          users.map(&:screen_name).each do |user|
            say user
          end
        end
      end
    end

    def protocol
      options['no_ssl'] ? 'http' : DEFAULT_PROTOCOL
    end

  end
end
