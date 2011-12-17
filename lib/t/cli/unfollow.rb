require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class Unfollow < Thor
      DEFAULT_HOST = 'api.twitter.com'
      DEFAULT_PROTOCOL = 'https'

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "users USER_NAME [USER_NAME...]", "Allows you to stop following users."
      def users(user_name, *user_names)
        user_names.unshift(user_name)
        users = user_names.map do |user_name|
          user_name = user_name.strip_at
          user = client.unfollow(user_name, :include_entities => false)
          say "@#{@rcfile.default_profile[0]} is no longer following @#{user.screen_name}."
          user
        end
        number = users.length
        say "@#{@rcfile.default_profile[0]} is no longer following #{number} #{number == 1 ? 'user' : 'users'}."
        say
        say "Run `#{$0} follow users #{user_names.join(' ')}` to follow again."
      end

      desc "all SUBCOMMAND ...ARGS", "Follow all users."
      require 't/cli/unfollow/all'
      subcommand 'all', CLI::Unfollow::All

    private

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
