require 'active_support/core_ext/array/conversions'
require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class Unfollow < Thor
    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'

    check_unknown_options!

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "users USERNAME [USERNAME...]", "Allows you to stop following users."
    def users(*usernames)
      users = usernames.map do |username|
        username = username.strip_at
        client.unfollow(username)
      end
      screen_names = users.map(&:screen_name)
      say "@#{@rcfile.default_profile[0]} is no longer following #{screen_names.map{|screen_name| "@#{screen_name}"}.to_sentence}."
      say
      say "Run `#{$0} follow users #{screen_names.join(' ')}` to follow again."
    end

    no_tasks do

      def base_url
        "#{protocol}://#{host}"
      end

      def client
        return @client if @client
        @rcfile.path = parent_options['profile'] if parent_options['profile']
        @client = Twitter::Client.new(
          :endpoint => base_url,
          :consumer_key => @rcfile.default_consumer_key,
          :consumer_secret => @rcfile.default_consumer_secret,
          :oauth_token => @rcfile.default_token,
          :oauth_token_secret  => @rcfile.default_secret
        )
      end

      def host
        parent_options['host'] || DEFAULT_HOST
      end

      def protocol
        parent_options['no_ssl'] ? 'http' : DEFAULT_PROTOCOL
      end

    end
  end
end
