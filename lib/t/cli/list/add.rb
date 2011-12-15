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

        desc "users LISTNAME USERNAME [USERNAME...]", "Add users to a list."
        def users(listname, username, *usernames)
          usernames.unshift(username)
          usernames.map!{|username| username.strip_at}
          client.list_add_members(listname, usernames)
          number = usernames.length
          say "@#{@rcfile.default_profile[0]} added #{number} #{number == 1 ? 'user' : 'users'} to the list: #{listname}."
          say
          say "Run `#{$0} list remove users #{listname} #{usernames.join(' ')}` to undo."
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
