require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class Unfollow
      class All < Thor
        DEFAULT_HOST = 'api.twitter.com'
        DEFAULT_PROTOCOL = 'https'

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "nonfollowers", "Unfollow all non-followers."
        def nonfollowers
          friend_ids = []
          cursor = -1
          until cursor == 0
            cursor = client.friend_ids(:cursor => cursor)
            friend_ids += cursor.ids
            cursor = cursor.next_cursor
          end
          follower_ids = []
          cursor = -1
          until cursor == 0
            cursor = client.follower_ids(:cursor => cursor)
            follower_ids += cursor.ids
            cursor = cursor.next_cursor
          end
          unfollow_ids = (friend_ids - follower_ids)
          number = unfollow_ids.length
          return say "@#{@rcfile.default_profile[0]} is already not following any non-followers." if number.zero?
          return unless yes? "Are you sure you want to unfollow #{number} #{number == 1 ? 'user' : 'users'}?"
          users = unfollow_ids.map do |unfollow_id|
            user = client.unfollow(unfollow_id)
            say "@#{@rcfile.default_profile[0]} is no longer following @#{user.screen_name}."
            user
          end
          say "@#{@rcfile.default_profile[0]} is no longer following #{number} #{number == 1 ? 'user' : 'users'}."
          say
          say "Run `#{$0} follow users #{users.map(&:screen_name).join(' ')}` to follow again."
        end

        desc "users", "Unfollow all users."
        def users
          friend_ids = []
          cursor = -1
          until cursor == 0
            cursor = client.friend_ids(:cursor => cursor)
            friend_ids += cursor.ids
            cursor = cursor.next_cursor
          end
          number = friend_ids.length
          return say "@#{@rcfile.default_profile[0]} is already not following anyone." if number.zero?
          return unless yes? "Are you sure you want to unfollow #{number} #{number == 1 ? 'user' : 'users'}?"
          users = friend_ids.map do |friend_id|
            user = client.unfollow(friend_id)
            say "@#{@rcfile.default_profile[0]} is no longer following @#{user.screen_name}."
            user
          end
          say "@#{@rcfile.default_profile[0]} is no longer following #{number} #{number == 1 ? 'user' : 'users'}."
          say
          say "Run `#{$0} follow users #{users.map(&:screen_name).join(' ')}` to follow again."
        end
        map %w(friends) => :users

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
