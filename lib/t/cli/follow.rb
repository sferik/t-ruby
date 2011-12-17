require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class Follow < Thor
      DEFAULT_HOST = 'api.twitter.com'
      DEFAULT_PROTOCOL = 'https'

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "users USER_NAME [USER_NAME...]", "Allows you to start following users."
      def users(user_name, *user_names)
        user_names.unshift(user_name)
        users = user_names.map do |user_name|
          user_name = user_name.strip_at
          user = client.follow(user_name, :include_entities => false)
          say "@#{@rcfile.default_profile[0]} is now following @#{user.screen_name}."
          user
        end
        number = users.length
        say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
        say
        say "Run `#{$0} unfollow users #{user_names.join(' ')}` to stop."
      end

      desc "all SUBCOMMAND ...ARGS", "Follow all users."
      require 't/cli/follow/all'
      subcommand 'all', CLI::Follow::All

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
