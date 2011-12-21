require 't/core_ext/enumerable'
require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List
      class Remove < Thor
        DEFAULT_HOST = 'api.twitter.com'
        DEFAULT_PROTOCOL = 'https'

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "users LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Remove users from a list."
        def users(list_name, screen_name, *screen_names)
          screen_names.unshift(screen_name)
          screen_names.threaded_map do |screen_name|
            screen_name = screen_name.strip_at
            client.list_remove_member(list_name, screen_name)
          end
          number = screen_names.length
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'user' : 'users'} from the list \"#{list_name}\"."
          say
          say "Run `#{$0} list add users #{list_name} #{screen_names.join(' ')}` to undo."
        end

        desc "all SUBCOMMAND ...ARGS", "Remove all users to a list."
        require 't/cli/list/remove/all'
        subcommand 'all', CLI::List::Remove::All

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
