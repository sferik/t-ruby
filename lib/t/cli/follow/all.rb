require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class Follow
      class All < Thor
        DEFAULT_HOST = 'api.twitter.com'
        DEFAULT_PROTOCOL = 'https'

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "followers", "Follow all followers."
        def followers
          follower_ids = []
          cursor = -1
          until cursor == 0
            cursor = client.follower_ids(:cursor => cursor)
            follower_ids += cursor.ids
            cursor = cursor.next_cursor
          end
          friend_ids = []
          cursor = -1
          until cursor == 0
            cursor = client.friend_ids(:cursor => cursor)
            friend_ids += cursor.ids
            cursor = cursor.next_cursor
          end
          follow_ids = (follower_ids - friend_ids)
          number = follow_ids.length
          return say "@#{@rcfile.default_profile[0]} is already following all of his or her followers." if number.zero?
          return unless yes? "Are you sure you want to follow #{number} #{number == 1 ? 'user' : 'users'}?"
          users = follow_ids.map do |follow_id|
            user = client.follow(follow_id)
            say "@#{@rcfile.default_profile[0]} is now following @#{user.screen_name}."
            user
          end
          say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
          say
          say "Run `#{$0} unfollow users #{users.map(&:screen_name).join(' ')}` to stop."
        end

        desc "listed LISTNAME", "Follow all members of a list."
        def listed(listname)
          list_members = []
          cursor = -1
          until cursor == 0
            cursor = client.list_members(listname, :cursor => cursor, :skip_status => true, :include_entities => false)
            list_members += cursor.users
            cursor = cursor.next_cursor
          end
          number = list_members.length
          return say "@#{@rcfile.default_profile[0]} is already following all list members." if number.zero?
          return unless yes? "Are you sure you want to follow #{number} #{number == 1 ? 'user' : 'users'}?"
          users = list_members.map do |list_member|
            user = client.follow(list_member.id)
            say "@#{@rcfile.default_profile[0]} is now following @#{user.screen_name}."
            user
          end
          say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
          say
          say "Run `#{$0} unfollow all listed #{listname}` to stop."
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
