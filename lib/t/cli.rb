# encoding: utf-8
require 'forwardable'
require 'oauth'
require 'thor'
require 'twitter'
require 't/collectable'
require 't/delete'
require 't/editor'
require 't/list'
require 't/printable'
require 't/rcfile'
require 't/requestable'
require 't/search'
require 't/set'
require 't/stream'
require 't/utils'

module T
  class CLI < Thor
    extend Forwardable
    include T::Collectable
    include T::Printable
    include T::Requestable
    include T::Utils

    DEFAULT_NUM_RESULTS = 20
    DIRECT_MESSAGE_HEADINGS = ["ID", "Posted at", "Screen name", "Text"]
    TREND_HEADINGS = ["WOEID", "Parent ID", "Type", "Name", "Country"]

    check_unknown_options!

    class_option "color", :aliases => "-C", :type => :string, :enum => %w(auto never), :default => "auto", :desc => "Control how color is used in output"
    class_option "profile", :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), T::RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
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
    method_option "display-uri", :aliases => "-d", :type => :boolean, :default => false, :desc => "Display the authorization URL instead of attempting to open it."
    def authorize
      @rcfile.path = options['profile'] if options['profile']
      if @rcfile.empty?
        say "Welcome! Before you can use t, you'll first need to register an"
        say "application with Twitter. Just follow the steps below:"
        say "  1. Sign in to the Twitter Developer site and click"
        say "     \"Create a new application\"."
        say "  2. Complete the required fields and submit the form."
        say "     Note: Your application must have a unique name."
        say "     We recommend: \"<your handle>/t\"."
        say "  3. Go to the Settings tab of your application, and change the"
        say "     Access setting to \"Read, Write and Access direct messages\"."
        say "  4. Go to the Details tab to view the consumer key and secret,"
        say "     which you'll need to copy and paste below when prompted."
        say
        ask "Press [Enter] to open the Twitter Developer site."
        say
      else
        say "It looks like you've already registered an application with Twitter."
        say "To authorize a new account, just follow the steps below:"
        say "  1. Sign in to the Twitter Developer site."
        say "  2. Select the application for which you'd like to authorize an account."
        say "  3. Copy and paste the consumer key and secret below when prompted."
        say
        ask "Press [Enter] to open the Twitter Developer site."
        say
      end
      require 'launchy'
      open_or_print( "https://dev.twitter.com/apps", :dry_run => options['display-uri'] )
      key = ask "Enter your consumer key:"
      secret = ask "Enter your consumer secret:"
      consumer = OAuth::Consumer.new(key, secret, :site => Twitter::REST::Client::ENDPOINT)
      request_token = consumer.get_request_token
      uri = generate_authorize_uri(consumer, request_token)
      say
      say "In a moment, you will be directed to the Twitter app authorization page."
      say "Perform the following steps to complete the authorization process:"
      say "  1. Sign in to Twitter."
      say "  2. Press \"Authorize app\"."
      say "  3. Copy and paste the supplied PIN below when prompted."
      say
      ask "Press [Enter] to open the Twitter app authorization page."
      say
      open_or_print(uri, :dry_run => options['display-uri'])
      pin = ask "Enter the supplied PIN:"
      access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
      oauth_response = access_token.get('/1.1/account/verify_credentials.json?include_entities=false&skip_status=true')
      screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first
      @rcfile[screen_name] = {
        key => {
          'username' => screen_name,
          'consumer_key' => key,
          'consumer_secret' => secret,
          'token' => access_token.token,
          'secret' => access_token.secret,
        }
      }
      @rcfile.active_profile = {'username' => screen_name, 'consumer_key' => key}
      say "Authorization successful."
    end

    desc "block USER [USER...]", "Block users."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def block(user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.block(users)
      end
      say "@#{@rcfile.active_profile[0]} blocked #{pluralize(number, 'user')}."
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
      direct_messages = collect_with_count(count) do |count_opts|
        client.direct_messages(count_opts)
      end
      direct_messages.reverse! if options['reverse']
      require 'htmlentities'
      if options['csv']
        require 'csv'
        say DIRECT_MESSAGE_HEADINGS.to_csv unless direct_messages.empty?
        direct_messages.each do |direct_message|
          say [direct_message.id, csv_formatted_time(direct_message), direct_message.sender.screen_name, HTMLEntities.new.decode(direct_message.text)].to_csv
        end
      elsif options['long']
        array = direct_messages.map do |direct_message|
          [direct_message.id, ls_formatted_time(direct_message), "@#{direct_message.sender.screen_name}", HTMLEntities.new.decode(direct_message.text).gsub(/\n+/, ' ')]
        end
        format = options['format'] || DIRECT_MESSAGE_HEADINGS.size.times.map{"%s"}
        print_table_with_headings(array, DIRECT_MESSAGE_HEADINGS, format)
      else
        direct_messages.each do |direct_message|
          print_message(direct_message.sender.screen_name, direct_message.text)
        end
      end
    end
    map %w(directmessages dms) => :direct_messages

    desc "direct_messages_sent", "Returns the #{DEFAULT_NUM_RESULTS} most recent Direct Messages you've sent."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def direct_messages_sent
      count = options['number'] || DEFAULT_NUM_RESULTS
      direct_messages = collect_with_count(count) do |count_opts|
        client.direct_messages_sent(count_opts)
      end
      direct_messages.reverse! if options['reverse']
      require 'htmlentities'
      if options['csv']
        require 'csv'
        say DIRECT_MESSAGE_HEADINGS.to_csv unless direct_messages.empty?
        direct_messages.each do |direct_message|
          say [direct_message.id, csv_formatted_time(direct_message), direct_message.recipient.screen_name, HTMLEntities.new.decode(direct_message.text)].to_csv
        end
      elsif options['long']
        array = direct_messages.map do |direct_message|
          [direct_message.id, ls_formatted_time(direct_message), "@#{direct_message.recipient.screen_name}", HTMLEntities.new.decode(direct_message.text).gsub(/\n+/, ' ')]
        end
        format = options['format'] || DIRECT_MESSAGE_HEADINGS.size.times.map{"%s"}
        print_table_with_headings(array, DIRECT_MESSAGE_HEADINGS, format)
      else
        direct_messages.each do |direct_message|
          print_message(direct_message.recipient.screen_name, direct_message.text)
        end
      end
    end
    map %w(directmessagessent sent_messages sentmessages sms) => :direct_messages_sent

    desc "groupies [USER]", "Returns the list of people who follow you but you don't follow back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def groupies(user=nil)
      user = if user
        require 't/core_ext/string'
        if options['id']
          user.to_i
        else
          user.strip_ats
        end
      else
        client.verify_credentials.screen_name
      end
      follower_ids = Thread.new do
        client.follower_ids(user).to_a
      end
      following_ids = Thread.new do
        client.friend_ids(user).to_a
      end
      disciple_ids = (follower_ids.value - following_ids.value)
      require 'retryable'
      users = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.users(disciple_ids)
      end
      print_users(users)
    end
    map %w(disciples) => :groupies

    desc "dm USER MESSAGE", "Sends that person a Direct Message."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    def dm(user, message)
      require 't/core_ext/string'
      user = if options['id']
        user.to_i
      else
        user.strip_ats
      end
      direct_message = client.direct_message_create(user, message)
      say "Direct Message sent from @#{@rcfile.active_profile[0]} to @#{direct_message.recipient.screen_name}."
    end
    map %w(d m) => :dm

    desc "does_contain [USER/]LIST USER", "Find out whether a list contains a user."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    def does_contain(list, user=nil)
      owner, list = extract_owner(list, options)
      if user.nil?
        user = @rcfile.active_profile[0]
      else
        require 't/core_ext/string'
        user = if options['id']
          user = client.user(user.to_i).screen_name
        else
          user.strip_ats
        end
      end
      if client.list_member?(owner, list, user)
        say "Yes, #{list} contains @#{user}."
      else
        say "No, #{list} does not contain @#{user}."
        exit 1
      end
    end
    map %w(dc doescontain) => :does_contain

    desc "does_follow USER [USER]", "Find out whether one user follows another."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    def does_follow(user1, user2=nil)
      require 't/core_ext/string'
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

    desc "favorite TWEET_ID [TWEET_ID...]", "Marks Tweets as favorites."
    def favorite(status_id, *status_ids)
      status_ids.unshift(status_id)
      status_ids.map!(&:to_i)
      require 'retryable'
      favorites = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.favorite(status_ids)
      end
      number = favorites.length
      say "@#{@rcfile.active_profile[0]} favorited #{pluralize(number, 'tweet')}."
      say
      say "Run `#{File.basename($0)} delete favorite #{status_ids.join(' ')}` to unfavorite."
    end
    map %w(fave favourite) => :favorite

    desc "favorites [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets you favorited."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "max_id", :aliases => "-m", :type => :numeric, :desc => "Returns only the results with an ID less than the specified ID."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "since_id", :aliases => "-s", :type => :numeric, :desc => "Returns only the results with an ID greater than the specified ID."
    def favorites(user=nil)
      count = options['number'] || DEFAULT_NUM_RESULTS
      opts = {}
      opts[:exclude_replies] = true if options['exclude'] == 'replies'
      opts[:include_rts] = false if options['exclude'] == 'retweets'
      opts[:max_id] = options['max_id'] if options['max_id']
      opts[:since_id] = options['since_id'] if options['since_id']
      if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      tweets = collect_with_count(count) do |count_opts|
        client.favorites(user, count_opts.merge(opts))
      end
      print_tweets(tweets)
    end
    map %w(faves favourites) => :favorites

    desc "follow USER [USER...]", "Allows you to start following users."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def follow(user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.follow(users)
      end
      say "@#{@rcfile.active_profile[0]} is now following #{pluralize(number, 'more user')}."
      say
      say "Run `#{File.basename($0)} unfollow #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to stop."
    end

    desc "followings [USER]", "Returns a list of the people you follow on Twitter."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def followings(user=nil)
      if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      following_ids = client.friend_ids(user).to_a
      require 'retryable'
      users = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.users(following_ids)
      end
      print_users(users)
    end

    desc "followers [USER]", "Returns a list of the people who follow you on Twitter."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def followers(user=nil)
      if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
      end
      follower_ids = client.follower_ids(user).to_a
      require 'retryable'
      users = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.users(follower_ids)
      end
      print_users(users)
    end

    desc "friends [USER]", "Returns the list of people who you follow and follow you back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def friends(user=nil)
      user = if user
        require 't/core_ext/string'
        if options['id']
          user.to_i
        else
          user.strip_ats
        end
      else
        client.verify_credentials.screen_name
      end
      following_ids = Thread.new do
        client.friend_ids(user).to_a
      end
      follower_ids = Thread.new do
        client.follower_ids(user).to_a
      end
      friend_ids = (following_ids.value & follower_ids.value)
      require 'retryable'
      users = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.users(friend_ids)
      end
      print_users(users)
    end

    desc "leaders [USER]", "Returns the list of people who you follow but don't follow you back."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def leaders(user=nil)
      user = if user
        require 't/core_ext/string'
        if options['id']
          user.to_i
        else
          user.strip_ats
        end
      else
        client.verify_credentials.screen_name
      end
      following_ids = Thread.new do
        client.friend_ids(user).to_a
      end
      follower_ids = Thread.new do
        client.follower_ids(user).to_a
      end
      leader_ids = (following_ids.value - follower_ids.value)
      require 'retryable'
      users = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.users(leader_ids)
      end
      print_users(users)
    end

    desc "lists [USER]", "Returns the lists created by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(members mode posted slug subscribers), :default => "slug", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def lists(user=nil)
      lists = if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
        client.lists(user)
      else
        client.lists
      end
      print_lists(lists)
    end

    desc "matrix", "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."
    def_delegator :"T::Stream.new", :matrix

    desc "mentions", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets mentioning you."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def mentions
      count = options['number'] || DEFAULT_NUM_RESULTS
      tweets = collect_with_count(count) do |count_opts|
        client.mentions(count_opts)
      end
      print_tweets(tweets)
    end
    map %w(replies) => :mentions

    desc "open USER", "Opens that user's profile in a web browser."
    method_option "display-uri", :aliases => "-d", :type => :boolean, :default => false, :desc => "Display the requested URL instead of attempting to open it."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "status", :aliases => "-s", :type => :boolean, :default => false, :desc => "Specify input as a Twitter status ID instead of a screen name."
    def open(user)
      require 'launchy'
      if options['id']
        user = client.user(user.to_i)
        open_or_print(user.website, :dry_run => options['display-uri'])
      elsif options['status']
        status = client.status(user.to_i, :include_my_retweet => false)
        open_or_print(status.uri, :dry_run => options['display-uri'])
      else
        require 't/core_ext/string'
        open_or_print("https://twitter.com/#{user.strip_ats}", :dry_run => options['display-uri'])
      end
    end

    desc "reply TWEET_ID MESSAGE", "Post your Tweet as a reply directed at another person."
    method_option "all", :aliases => "-a", :type => :boolean, :default => false, :desc => "Reply to all users mentioned in the Tweet."
    method_option "location", :aliases => "-l", :type => :string, :default => "location", :desc => "Add location information. If the optional 'latitude,longitude' parameter is not supplied, looks up location by IP address."
    def reply(status_id, message)
      status = client.status(status_id.to_i, :include_my_retweet => false)
      users = Array(status.user.screen_name)
      if options['all']
        users += extract_mentioned_screen_names(status.full_text)
        users.uniq!
      end
      require 't/core_ext/string'
      users.map!(&:prepend_at)
      opts = {:in_reply_to_status_id => status.id, :trim_user => true}
      add_location!(options, opts)
      reply = client.update("#{users.join(' ')} #{message}", opts)
      say "Reply posted by @#{@rcfile.active_profile[0]} to #{users.join(' ')}."
      say
      say "Run `#{File.basename($0)} delete status #{reply.id}` to delete."
    end

    desc "report_spam USER [USER...]", "Report users for spam."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def report_spam(user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.report_spam(users)
      end
      say "@#{@rcfile.active_profile[0]} reported #{pluralize(number, 'user')}."
    end
    map %w(report reportspam spam) => :report_spam

    desc "retweet TWEET_ID [TWEET_ID...]", "Sends Tweets to your followers."
    def retweet(status_id, *status_ids)
      status_ids.unshift(status_id)
      status_ids.map!(&:to_i)
      require 'retryable'
      retweets = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        client.retweet(status_ids, :trim_user => true)
      end
      number = retweets.length
      say "@#{@rcfile.active_profile[0]} retweeted #{pluralize(number, 'tweet')}."
      say
      say "Run `#{File.basename($0)} delete status #{retweets.map{|tweet| tweet.retweeted_status.id}.join(' ')}` to undo."
    end
    map %w(rt) => :retweet

    desc "retweets [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Retweets by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def retweets(user=nil)
      count = options['number'] || DEFAULT_NUM_RESULTS
      tweets = if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
        collect_with_count(count) do |count_opts|
          client.retweeted_by_user(user, count_opts)
        end
      else
        collect_with_count(count) do |count_opts|
          client.retweeted_by_me(count_opts)
        end
      end
      print_tweets(tweets)
    end
    map %w(rts) => :retweets

    desc "ruler", "Prints a 140-character ruler"
    method_option "indent", :aliases => "-i", :type => :numeric, :default => 0, :desc => "The number of space to print before the ruler."
    def ruler
      say "#{' ' * options['indent'].to_i}----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|"
    end

    desc "status TWEET_ID", "Retrieves detailed information about a Tweet."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def status(status_id)
      status = client.status(status_id.to_i, :include_my_retweet => false)
      location = if status.place?
        if status.place.name && status.place.attributes && status.place.attributes[:street_address] && status.place.attributes[:locality] && status.place.attributes[:region] && status.place.country
          [status.place.name, status.place.attributes[:street_address], status.place.attributes[:locality], status.place.attributes[:region], status.place.country].join(", ")
        elsif status.place.name && status.place.attributes && status.place.attributes[:locality] && status.place.attributes[:region] && status.place.country
          [status.place.name, status.place.attributes[:locality], status.place.attributes[:region], status.place.country].join(", ")
        elsif status.place.full_name && status.place.attributes && status.place.attributes[:region] && status.place.country
          [status.place.full_name, status.place.attributes[:region], status.place.country].join(", ")
        elsif status.place.full_name && status.place.country
          [status.place.full_name, status.place.country].join(", ")
        elsif status.place.full_name
          status.place.full_name
        else
          status.place.name
        end
      elsif status.geo?
        reverse_geocode(status.geo)
      end
      status_headings = ["ID", "Posted at", "Screen name", "Text", "Retweets", "Favorites", "Source", "Location"]
      if options['csv']
        require 'csv'
        say status_headings.to_csv
        say [status.id, csv_formatted_time(status), status.user.screen_name, decode_full_text(status), status.retweet_count, status.favorite_count, strip_tags(status.source), location].to_csv
      elsif options['long']
        array = [status.id, ls_formatted_time(status), "@#{status.user.screen_name}", decode_full_text(status).gsub(/\n+/, ' '), status.retweet_count, status.favorite_count, strip_tags(status.source), location]
        format = options['format'] || status_headings.size.times.map{"%s"}
        print_table_with_headings([array], status_headings, format)
      else
        array = []
        array << ["ID", status.id.to_s]
        array << ["Text", decode_full_text(status).gsub(/\n+/, ' ')]
        array << ["Screen name", "@#{status.user.screen_name}"]
        array << ["Posted at", "#{ls_formatted_time(status)} (#{time_ago_in_words(status.created_at)} ago)"]
        array << ["Retweets", number_with_delimiter(status.retweet_count)]
        array << ["Favorites", number_with_delimiter(status.favorite_count)]
        array << ["Source", strip_tags(status.source)]
        array << ["Location", location] unless location.nil?
        print_table(array)
      end
    end

    desc "timeline [USER]", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets posted by a user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "exclude", :aliases => "-e", :type => :string, :enum => %w(replies retweets), :desc => "Exclude certain types of Tweets from the results.", :banner => "TYPE"
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "max_id", :aliases => "-m", :type => :numeric, :desc => "Returns only the results with an ID less than the specified ID."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "since_id", :aliases => "-s", :type => :numeric, :desc => "Returns only the results with an ID greater than the specified ID."
    def timeline(user=nil)
      count = options['number'] || DEFAULT_NUM_RESULTS
      opts = {}
      opts[:exclude_replies] = true if options['exclude'] == 'replies'
      opts[:include_rts] = false if options['exclude'] == 'retweets'
      opts[:max_id] = options['max_id'] if options['max_id']
      opts[:since_id] = options['since_id'] if options['since_id']
      if user
        require 't/core_ext/string'
        user = if options['id']
          user.to_i
        else
          user.strip_ats
        end
        tweets = collect_with_count(count) do |count_opts|
          client.user_timeline(user, count_opts.merge(opts))
        end
      else
        tweets = collect_with_count(count) do |count_opts|
          client.home_timeline(count_opts.merge(opts))
        end
      end
      print_tweets(tweets)
    end
    map %w(tl) => :timeline

    desc "trends [WOEID]", "Returns the top 10 trending topics."
    method_option "exclude-hashtags", :aliases => "-x", :type => :boolean, :default => false, :desc => "Remove all hashtags from the trends list."
    def trends(woe_id=1)
      opts = {}
      opts.merge!(:exclude => "hashtags") if options['exclude-hashtags']
      trends = client.trends(woe_id, opts)
      print_attribute(trends, :name)
    end

    desc "trend_locations", "Returns the locations for which Twitter has trending topic information."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(country name parent type woeid), :default => "name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def trend_locations
      places = client.trend_locations
      places = case options['sort']
      when 'country'
        places.sort_by{|places| places.country.downcase}
      when 'parent'
        places.sort_by{|places| places.parent_id.to_i}
      when 'type'
        places.sort_by{|places| places.place_type.downcase}
      when 'woeid'
        places.sort_by{|places| places.woeid.to_i}
      else
        places.sort_by{|places| places.name.downcase}
      end unless options['unsorted']
      places.reverse! if options['reverse']
      if options['csv']
        require 'csv'
        say TREND_HEADINGS.to_csv unless places.empty?
        places.each do |place|
          say [place.woeid, place.parent_id, place.place_type, place.name, place.country].to_csv
        end
      elsif options['long']
        array = places.map do |place|
          [place.woeid, place.parent_id, place.place_type, place.name, place.country]
        end
        format = options['format'] || TREND_HEADINGS.size.times.map{"%s"}
        print_table_with_headings(array, TREND_HEADINGS, format)
      else
        print_attribute(places, :name)
      end
    end
    map %w(locations trendlocations) => :trend_locations

    desc "unfollow USER [USER...]", "Allows you to stop following users."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def unfollow(user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.unfollow(users)
      end
      say "@#{@rcfile.active_profile[0]} is no longer following #{pluralize(number, 'user')}."
      say
      say "Run `#{File.basename($0)} follow #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to follow again."
    end

    desc "update [MESSAGE]", "Post a Tweet."
    method_option "location", :aliases => "-l", :type => :string, :default => "location", :desc => "Add location information. If the optional 'latitude,longitude' parameter is not supplied, looks up location by IP address."
    method_option "file", :aliases => "-f", :type => :string, :desc => "The path to an image to attach to your tweet."
    def update(message=nil)
      message = T::Editor.gets if message.nil? || message.empty?
      opts = {:trim_user => true}
      add_location!(options, opts)
      status = if options['file']
        client.update_with_media(message, File.new(File.expand_path(options['file'])), opts)
      else
        client.update(message, opts)
      end
      say "Tweet posted by @#{@rcfile.active_profile[0]}."
      say
      say "Run `#{File.basename($0)} delete status #{status.id}` to delete."
    end
    map %w(post tweet) => :update

    desc "users USER [USER...]", "Returns a list of users you specify."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def users(user, *users)
      users.unshift(user)
      require 't/core_ext/string'
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
      require 't/version'
      say T::Version
    end
    map %w(-v --version) => :version

    desc "whois USER", "Retrieves profile information for the user."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def whois(user)
      require 't/core_ext/string'
      user = if options['id']
        user.to_i
      else
        user.strip_ats
      end
      user = client.user(user)
      require 'htmlentities'
      if options['csv'] || options['long']
        print_users([user])
      else
        array = []
        array << ["ID", user.id.to_s]
        array << ["Since", "#{ls_formatted_time(user)} (#{time_ago_in_words(user.created_at)} ago)"]
        array << ["Last update", "#{decode_full_text(user.status).gsub(/\n+/, ' ')} (#{time_ago_in_words(user.status.created_at)} ago)"] unless user.status.nil?
        array << ["Screen name", "@#{user.screen_name}"]
        array << [user.verified ? "Name (Verified)" : "Name", user.name] unless user.name.nil?
        array << ["Tweets", number_with_delimiter(user.statuses_count)]
        array << ["Favorites", number_with_delimiter(user.favorites_count)]
        array << ["Listed", number_with_delimiter(user.listed_count)]
        array << ["Following", number_with_delimiter(user.friends_count)]
        array << ["Followers", number_with_delimiter(user.followers_count)]
        array << ["Bio", user.description.gsub(/\n+/, ' ')] unless user.description.nil?
        array << ["Location", user.location] unless user.location.nil?
        array << ["URL", user.website] unless user.website.nil?
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

    def extract_mentioned_screen_names(text)
      valid_mention_preceding_chars = /(?:[^a-zA-Z0-9_!#\$%&*@＠]|^|RT:?)/o
      at_signs = /[@＠]/
      valid_mentions = /
        (#{valid_mention_preceding_chars})  # $1: Preceeding character
        (#{at_signs})                       # $2: At mark
        ([a-zA-Z0-9_]{1,20})                # $3: Screen name
      /ox

      return [] if text !~ at_signs

      text.to_s.scan(valid_mentions).map do |before, at, screen_name|
        screen_name
      end
    end

    def generate_authorize_uri(consumer, request_token)
      request = consumer.create_signed_request(:get, consumer.authorize_path, request_token, pin_auth_parameters)
      params = request['Authorization'].sub(/^OAuth\s+/, '').split(/,\s+/).map do |param|
        key, value = param.split('=')
        value =~ /"(.*?)"/
        "#{key}=#{CGI::escape($1)}"
      end.join('&')
      "#{Twitter::REST::Client::ENDPOINT}#{request.path}?#{params}"
    end

    def pin_auth_parameters
      {:oauth_callback => 'oob'}
    end

    def add_location!(options, opts)
      if options['location']
        lat, lng = options['location'] == 'location' ? [location.lat, location.lng] : options['location'].split(',').map(&:to_f)
        opts.merge!(:lat => lat, :long => lng)
      end
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

    def reverse_geocode(geo)
      require 'geokit'
      geoloc = Geokit::Geocoders::MultiGeocoder.reverse_geocode(geo.coordinates)
      if geoloc.city && geoloc.state && geoloc.country
        [geoloc.city, geoloc.state, geoloc.country].join(", ")
      elsif geoloc.state && geoloc.country
        [geoloc.state, geoloc.country].join(", ")
      else
        geoloc.country
      end
    end

  end
end
