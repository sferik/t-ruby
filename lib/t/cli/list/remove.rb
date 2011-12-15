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

        desc "users LISTNAME USERNAME [USERNAME...]", "Remove users from a list."
        def users(listname, username, *usernames)
          usernames.unshift(username)
          usernames.each do |username|
            username = username.strip_at
            client.list_remove_member(listname, username)
            say "@#{@rcfile.default_profile[0]} removed @#{username} from the list: #{listname}."
          end
          number = usernames.length
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'user' : 'users'} from the list: #{listname}."
          say
          say "Run `#{$0} list add users #{listname} #{usernames.join(' ')}` to undo."
        end

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
