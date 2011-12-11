require 'active_support/core_ext/array/conversions'
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
          users = (follower_ids - friend_ids).map do |friend_id|
            client.follow(friend_id)
          end
          screen_names = users.map(&:screen_name)
          say "@#{@rcfile.default_profile[0]} is now following #{screen_names.map{|screen_name| "@#{screen_name}"}.to_sentence}."
          say
          say "Run `#{$0} unfollow users #{screen_names.join(' ')}` to stop."
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
