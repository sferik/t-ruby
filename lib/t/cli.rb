require 'action_view'
require 'launchy'
require 'oauth'
require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'time'
require 'twitter'
require 'yaml'

module T
  class CLI < Thor
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper

    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'
    DEFAULT_RPP = 20
    MAX_SCREEN_NAME_SIZE = 20

    class_option :host, :aliases => "-H", :type => :string, :default => DEFAULT_HOST, :desc => "Twitter API server"
    class_option :no_ssl, :aliases => "-U", :type => :boolean, :default => false, :desc => "Disable SSL"
    class_option :profile, :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

    check_unknown_options!

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
      say "Authorization successful"
    end

    desc "block SCREEN_NAME", "Block a user."
    def block(screen_name)
      screen_name = screen_name.strip_at
      user = client.block(screen_name, :include_entities => false)
      say "@#{@rcfile.default_profile[0]} blocked @#{user.screen_name}"
      say
      say "Run `#{$0} delete block #{user.screen_name}` to unblock."
    end

    desc "direct_messages", "Returns the 20 most recent Direct Messages sent to you."
    def direct_messages
      run_pager
      client.direct_messages(:include_entities => false).each do |direct_message|
        say "#{direct_message.sender.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text} (#{time_ago_in_words(direct_message.created_at)} ago)"
      end
    end
    map %w(dms) => :direct_messages

    desc "dm SCREEN_NAME MESSAGE", "Sends that person a Direct Message."
    def dm(screen_name, message)
      screen_name = screen_name.strip_at
      direct_message = client.direct_message_create(screen_name, message, :include_entities => false)
      say "Direct Message sent from @#{@rcfile.default_profile[0]} to @#{direct_message.recipient.screen_name} (#{time_ago_in_words(direct_message.created_at)} ago)"
    end
    map %w(m) => :dm

    desc "favorite SCREEN_NAME", "Marks that user's last Tweet as one of your favorites."
    def favorite(screen_name)
      screen_name = screen_name.strip_at
      user = client.user(screen_name, :include_entities => false)
      if user.status
        client.favorite(user.status.id, :include_entities => false)
        say "@#{@rcfile.default_profile[0]} favorited @#{user.screen_name}'s latest status: \"#{user.status.text}\""
        say
        say "Run `#{$0} delete favorite` to unfavorite."
      else
        raise Thor::Error, "Tweet not found"
      end
    rescue Twitter::Error::Forbidden => error
      if error.message =~ /You have already favorited this status\./
        say "@#{@rcfile.default_profile[0]} favorited @#{user.screen_name}'s latest status: \"#{user.status.text}\""
      else
        raise
      end
    end
    map %w(fave) => :favorite

    desc "favorites", "Returns the #{DEFAULT_RPP} most recent Tweets you favorited."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_RPP
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def favorites
      hash = {:include_entities => false}
      hash.merge!(:count => options['number']) if options['number']
      timeline = client.favorites(hash)
      timeline.reverse! if options['reverse']
      run_pager
      timeline.each do |status|
        say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
      end
    end
    map %w(faves) => :favorites

    desc "mentions", "Returns the #{DEFAULT_RPP} most recent Tweets mentioning you."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_RPP
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def mentions
      hash = {:include_entities => false}
      hash.merge!(:count => options['number']) if options['number']
      timeline = client.mentions(hash)
      timeline.reverse! if options['reverse']
      run_pager
      timeline.each do |status|
        say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
      end
    end
    map %w(replies) => :mentions

    desc "open SCREEN_NAME", "Opens that user's profile in a web browser."
    method_option :dry_run, :type => :boolean
    def open(screen_name)
      screen_name = screen_name.strip_at
      Launchy.open("https://twitter.com/#{screen_name}", :dry_run => options.fetch('dry_run', false))
    end

    desc "reply SCREEN_NAME MESSAGE", "Post your Tweet as a reply directed at another person."
    method_option :location, :aliases => "-l", :type => :boolean, :default => true
    def reply(screen_name, message)
      screen_name = screen_name.strip_at
      hash = {:include_entities => false, :trim_user => true}
      hash.merge!(:lat => location.lat, :long => location.lng) if options['location']
      user = client.user(screen_name, :include_entities => false)
      hash.merge!(:in_reply_to_status_id => user.status.id) if user.status
      status = client.update("@#{user.screen_name} #{message}", hash)
      say "Reply created by @#{@rcfile.default_profile[0]} to @#{user.screen_name} (#{time_ago_in_words(status.created_at)} ago)"
      say
      say "Run `#{$0} delete status` to delete."
    end

    desc "retweet SCREEN_NAME", "Sends that user's latest Tweet to your followers."
    def retweet(screen_name)
      screen_name = screen_name.strip_at
      user = client.user(screen_name, :include_entities => false)
      if user.status
        client.retweet(user.status.id, :include_entities => false, :trim_user => true)
        say "@#{@rcfile.default_profile[0]} retweeted @#{user.screen_name}'s latest status: \"#{user.status.text}\""
        say
        say "Run `#{$0} delete status` to undo."
      else
        raise Thor::Error, "Tweet not found"
      end
    rescue Twitter::Error::Forbidden => error
      if error.message =~ /sharing is not permissable for this status \(Share validations failed\)/
        say "@#{@rcfile.default_profile[0]} retweeted @#{user.screen_name}'s latest status: \"#{user.status.text}\""
      else
        raise
      end
    end
    map %w(rt) => :retweet

    desc "sent_messages", "Returns the 20 most recent Direct Messages sent to you."
    def sent_messages
      run_pager
      client.direct_messages_sent(:include_entities => false).each do |direct_message|
        say "#{direct_message.recipient.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{direct_message.text} (#{time_ago_in_words(direct_message.created_at)} ago)"
      end
    end
    map %w(sms) => :sent_messages

    desc "stats SCREEN_NAME", "Retrieves the given user's number of followers and how many people they're following."
    def stats(screen_name)
      screen_name = screen_name.strip_at
      user = client.user(screen_name, :include_entities => false)
      say "Tweets: #{number_with_delimiter(user.statuses_count)}"
      say "Following: #{number_with_delimiter(user.friends_count)}"
      say "Followers: #{number_with_delimiter(user.followers_count)}"
      say "Favorites: #{number_with_delimiter(user.favorites_count)}"
      say "Listed: #{number_with_delimiter(user.listed_count)}"
      say
      say "Run `#{$0} whois #{user.screen_name}` to view profile."
    end

    desc "status MESSAGE", "Post a Tweet."
    method_option :location, :aliases => "-l", :type => :boolean, :default => true
    def status(message)
      hash = {:include_entities => false, :trim_user => true}
      hash.merge!(:lat => location.lat, :long => location.lng) if options['location']
      status = client.update(message, hash)
      say "Tweet created by @#{@rcfile.default_profile[0]} (#{time_ago_in_words(status.created_at)} ago)"
      say
      say "Run `#{$0} delete status` to delete."
    end
    map %w(post tweet update) => :status

    desc "suggest", "This command returns a listing of Twitter users' accounts we think you might enjoy following."
    def suggest
      recommendation = client.recommendations(:limit => 1, :include_entities => false).first
      if recommendation
        say "Try following @#{recommendation.screen_name}."
        say
        say "Run `#{$0} follow #{recommendation.screen_name}` to follow."
        say "Run `#{$0} whois #{recommendation.screen_name}` for profile."
        say "Run `#{$0} suggest` for another recommendation."
      end
    end

    desc "timeline [SCREEN_NAME]", "Returns the #{DEFAULT_RPP} most recent Tweets posted by a user."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_RPP
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
    def timeline(screen_name=nil)
      hash = {:include_entities => false}
      hash.merge!(:count => options['number']) if options['number']
      if screen_name
        screen_name = screen_name.strip_at
        timeline = client.user_timeline(screen_name, hash)
      else
        timeline = client.home_timeline(hash)
      end
      timeline.reverse! if options['reverse']
      run_pager
      timeline.each do |status|
        say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
      end
    end
    map %w(tl) => :timeline

    desc "version", "Show version."
    def version
      say T::Version
    end
    map %w(-v --version) => :version

    desc "whois SCREEN_NAME", "Retrieves profile information for the user."
    def whois(screen_name)
      screen_name = screen_name.strip_at
      user = client.user(screen_name, :include_entities => false)
      say "#{user.name}, since #{user.created_at.strftime("%b %Y")}."
      say "bio: #{user.description}"
      say "location: #{user.location}"
      say "web: #{user.url}"
    end

    desc "delete SUBCOMMAND ...ARGS", "Delete Tweets, Direct Messages, etc."
    method_option :force, :aliases => "-f", :type => :boolean
    require 't/cli/delete'
    subcommand 'delete', CLI::Delete

    desc "follow SUBCOMMAND ...ARGS", "Follow users."
    require 't/cli/follow'
    subcommand 'follow', CLI::Follow

    desc "list SUBCOMMAND ...ARGS", "Do various things with lists."
    require 't/cli/list'
    subcommand 'list', CLI::List

    desc "search SUBCOMMAND ...ARGS", "Search through Tweets."
    require 't/cli/search'
    subcommand 'search', CLI::Search

    desc "set SUBCOMMAND ...ARGS", "Change various account settings."
    require 't/cli/set'
    subcommand 'set', CLI::Set

    desc "unfollow SUBCOMMAND ...ARGS", "Unfollow users."
    require 't/cli/unfollow'
    subcommand 'unfollow', CLI::Unfollow

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

    def protocol
      options['no_ssl'] ? 'http' : DEFAULT_PROTOCOL
    end

    def run_pager
      return if RUBY_PLATFORM =~ /win32/
      return if ENV["T_ENV"] == "test"
      return unless STDOUT.tty?

      read, write = IO.pipe

      unless Kernel.fork # Child process
        STDOUT.reopen(write)
        STDERR.reopen(write) if STDERR.tty?
        read.close
        write.close
        return
      end

      # Parent process, become pager
      STDIN.reopen(read)
      read.close
      write.close

      ENV['LESS'] = 'FSRX' # Don't page if the input is short enough

      Kernel.select [STDIN] # Wait until we have input before we start the pager
      pager = ENV['PAGER'] || 'less'
      exec pager rescue exec "/bin/sh", "-c", pager
    end

  end
end
