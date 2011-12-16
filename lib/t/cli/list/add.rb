require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List
      class Add < Thor
        DEFAULT_HOST = 'api.twitter.com'
        DEFAULT_PROTOCOL = 'https'

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "users LIST_NAME USER_NAME [USER_NAME...]", "Add users to a list."
        def users(list_name, user_name, *user_names)
          user_names.unshift(user_name)
          user_names.map!{|user_name| user_name.strip_at}
          client.list_add_members(list_name, user_names)
          number = user_names.length
          say "@#{@rcfile.default_profile[0]} added #{number} #{number == 1 ? 'user' : 'users'} to the list \"#{list_name}\"."
          say
          say "Run `#{$0} list remove users #{list_name} #{user_names.join(' ')}` to undo."
        end

        desc "all SUBCOMMAND ...ARGS", "Add all users to a list."
        require 't/cli/list/add/all'
        subcommand 'all', CLI::List::Add::All

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
end
