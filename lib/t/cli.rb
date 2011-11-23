require 'action_view'
require 'launchy'
require 'oauth'
require 't/rcfile'
require 't/set'
require 'thor'
require 'time'
require 'twitter'
require 'yaml'

module T
  class CLI < Thor
    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'

    class_option "host", :aliases => "-H", :default => DEFAULT_HOST
    class_option "no-ssl", :aliases => "-U", :type => :boolean, :default => false

    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper

    desc "accounts", "List accounts"
    def accounts
      rcfile = RCFile.instance
      rcfile.profiles.each do |profile|
        say profile[0]
        profile[1].keys.each do |key|
          say "  #{key}#{rcfile.default_profile[0] == profile[0] && rcfile.default_profile[1] == key ? " (default)" : nil}"
        end
      end
    end
    map %w(list ls) => :accounts

    desc "authorize", "Allows an application to request user authorization"
    option "consumer-key", :aliases => "-c", :required => true
    option "consumer-secret", :aliases => "-s", :required => true
    option "access-token", :aliases => "-a"
    option "token-secret", :aliases => "-S"
    def authorize
      request_token = consumer.get_request_token
      url = generate_authorize_url(request_token)
      say "Authorize this app and copy the supplied PIN to complete the authorization process."
      print "Your default web browser will open in "
      9.downto(1) do |i|
        sleep 0.2
        print i
        4.times do
          sleep 0.2
          print '.'
        end
      end
      Launchy.open(url)
      pin = ask "\nPaste in the supplied PIN:"
      access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
      oauth_response = access_token.get('/1/account/verify_credentials.json')
      username = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first
      rcfile = RCFile.instance
      rcfile[username] = {
        options['consumer-key'] => {
          'username' => username,
          'consumer_key' => options['consumer-key'],
          'consumer_secret' => options['consumer-secret'],
          'token' => access_token.token,
          'secret' => access_token.secret,
        }
      }
      rcfile.default_profile = {'username' => username, 'consumer_key' => options['consumer-key']}
      say "Authorization successful"
    rescue OAuth::Unauthorized
      raise Exception, "Authorization failed. Check that your consumer key and secret are correct, as well as your username and password."
    end

    desc "block USERNAME", "Block a user."
    def block(username)
      client.block(username)
      say "Blocked @#{username}"
      say
      say "Run `#{$0} unblock #{username}` to unblock."
    end

    desc "direct_messages", "Returns the 20 most recent Direct Messages sent to you."
    def direct_messages
      client.direct_messages.each do |direct_message|
        say "#{direct_message.sender.screen_name.rjust(20)}: #{direct_message.text} (#{time_ago_in_words(direct_message.created_at)} ago)"
      end
    end

    desc "sent_messages", "Returns the 20 most recent Direct Messages sent to you."
    def sent_messages
      client.direct_messages_sent.each do |direct_message|
        say "#{direct_message.recipient.screen_name.rjust(20)}: #{direct_message.text} (#{time_ago_in_words(direct_message.created_at)} ago)"
      end
    end

    desc "dm USERNAME MESSAGE", "Sends that person a Direct Message."
    def dm(username, message)
      direct_message = client.direct_message_create(username, message)
      say "Direct Message sent to @#{username} (#{time_ago_in_words(status.created_at)} ago)"
    end
    map :m => :dm

    desc "favorite USERNAME", "Marks that user's last Tweet as one of your favorites."
    def favorite(username)
      status = client.user_timeline(username).first
      begin
        client.favorite(status.id)
        say "You have favorited @#{username}'s latest tweet: #{status.text}"
      rescue Twitter::Error::Forbidden => error
        say "You have already favorited this status."
      end
    end

    desc "follow USERNAME", "Allows you to start following a specific user."
    def follow(username)
      user = client.follow(username)
      say "You're now following @#{username}. Run `#{$0} unfollow #{username}` to stop."
      recommendations = client.recommendations(:user_id => user.id, :limit => 2)
      say
      say "Try following @#{recommendations[0].screen_name} or @#{recommendations[1].screen_name}."
      status = client.user_timeline(username).first
      say "#{username}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
    end
    map :befriend => :follow

    desc "get USERNAME", "Retrieves the latest update posted by the user."
    def get(username)
      status = client.user_timeline(username).first
      say "#{status.text} (#{time_ago_in_words(status.created_at)} ago)"
    end

    desc "mentions", "Returns the 20 most recent Tweets mentioning you."
    option "reverse", :aliases => "-r", :type => :boolean, :default => false
    def mentions
      timeline = client.mentions
      timeline.reverse! if options['reverse']
      timeline.each do |status|
        say "#{status.user.screen_name.rjust(20)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
      end
    end
    map :replies => :mentions

    desc "open USERNAME", "Opens that user's profile in a web browser."
    def open(username)
      Launchy.open("https://twitter.com/#{username}")
    end

    desc "reply USERNAME MESSAGE", "Post your Tweet as a reply directed at another person."
    def reply(username, message)
      in_reply_to_status = client.user_timeline(username).first
      status = client.update("@#{username} #{message}", :in_reply_to_status_id => in_reply_to_status.id)
      say "Reply created (#{time_ago_in_words(status.created_at)} ago)"
    end

    desc "retweet USERNAME", "Sends that user's latest Tweet to your followers."
    def retweet(username)
      status = client.user_timeline(username).first
      client.retweet(status.id)
      say "You have retweeted @#{username}'s latest tweet: #{status.text}"
    end
    map :rt => :retweet

    desc "stats USERNAME", "Retrieves the given user's number of followers and how many people they're following."
    def stats(username)
      user = client.user(username)
      say "Followers: #{number_with_delimiter(user.followers_count)}"
      say "Following: #{number_with_delimiter(user.friends_count)}"
      say
      say "Run `#{$0} whois #{username}` to view profile."
    end

    desc "suggest", "This command returns a listing of Twitter users' accounts we think you might enjoy following."
    def suggest
      recommendations = client.recommendations(:limit => 2)
      say "Try following @#{recommendations[0].screen_name} or @#{recommendations[1].screen_name}."
      say
      say "Run `#{$0} follow USERNAME` to follow."
      say "Run `#{$0} whois USERNAME` for profile."
      say "Run `#{$0} suggest` for more."
    end

    desc "timeline", "Returns the 20 most recent Tweets posted by you and the users you follow."
    option "reverse", :aliases => "-r", :type => :boolean, :default => false
    def timeline
      timeline = client.home_timeline
      timeline.reverse! if options['reverse']
      timeline.each do |status|
        say "#{status.user.screen_name.rjust(20)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
      end
    end
    map :tl => :timeline

    desc "unblock USERNAME", "Unblock a user."
    def unblock(username)
      client.unblock(username)
      say "Unblocked @#{username}"
      say
      say "Run `#{$0} block #{username}` to block."
    end

    desc "unfavorite USERNAME", "Marks that user's last Tweet as one of your favorites."
    def unfavorite(username)
      status = client.user_timeline(username).first
      client.unfavorite(status.id)
      say "You have unfavorited @#{username}'s latest tweet: #{status.text}"
    end

    desc "unfollow USERNAME", "Allows you to stop following a specific user."
    def unfollow(username)
      user = client.unfollow(username)
      say "You are no longer following @#{username}. Run `#{$0} follow #{username}` to follow again."
    end
    map :defriend => :unfollow

    desc "update MESSAGE", "Post a Tweet."
    def update(message)
      status = client.update(message)
      say "Tweet created (#{time_ago_in_words(status.created_at)} ago)"
    end
    map :post => :update

    desc "whois USERNAME", "Retrieves profile information for the user."
    def whois(username)
      user = client.user(username)
      output = []
      output << "#{user.name}, since #{user.created_at.strftime("%b %Y")}."
      output << "bio: #{user.description}"
      output << "location: #{user.location}"
      output << "web: #{user.url}"
      say output.join("\n")
    end

    desc "version", "Show version"
    def version
      say T::Version
    end
    map %w(-v --version) => :version

    desc "set SUBCOMMAND ...ARGS", "Change various account settings."
    subcommand 'set', Set

    no_tasks do

      def access_token
        OAuth::AccessToken.new(consumer, token, secret)
      end

      def base_url
        "#{protocol}://#{host}"
      end

      def client
        rcfile = RCFile.instance
        Twitter::Client.new(
          :endpoint => base_url,
          :consumer_key => rcfile.default_consumer_key,
          :consumer_secret => rcfile.default_consumer_secret,
          :oauth_token => rcfile.default_token,
          :oauth_token_secret  => rcfile.default_secret
        )
      end

      def consumer
        OAuth::Consumer.new(
          options['consumer-key'],
          options['consumer-secret'],
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

      def pin_auth_parameters
        {:oauth_callback => 'oob'}
      end

      def protocol
        options['no-ssl'] ? 'http' : DEFAULT_PROTOCOL
      end

    end
  end
end
