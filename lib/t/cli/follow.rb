require 'retryable'
require 't/core_ext/enumerable'
require 't/core_ext/string'
require 't/collectable'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class CLI
    class Follow < Thor
      include T::Collectable
      include T::Requestable

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "followers", "Follow all followers."
      def followers
        follower_ids = collect_with_cursor do |cursor|
          client.follower_ids(:cursor => cursor)
        end
        friend_ids = collect_with_cursor do |cursor|
          client.friend_ids(:cursor => cursor)
        end
        follow_ids = (follower_ids - friend_ids)
        number = follow_ids.length
        return say "@#{@rcfile.default_profile[0]} is already following all followers." if number.zero?
        return unless yes? "Are you sure you want to follow #{number} #{number == 1 ? 'user' : 'users'}?"
        screen_names = follow_ids.threaded_map do |follow_id|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.follow(follow_id, :include_entities => false)
          end
        end
        say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
        say
        say "Run `#{File.basename($0)} unfollow all followers` to stop."
      end

      desc "listed LIST_NAME", "Follow all members of a list."
      def listed(list_name)
        list_member_collection = collect_with_cursor do |cursor|
          client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
        end
        number = list_member_collection.length
        return say "@#{@rcfile.default_profile[0]} is already following all list members." if number.zero?
        return unless yes? "Are you sure you want to follow #{number} #{number == 1 ? 'user' : 'users'}?"
        list_member_collection.threaded_map do |list_member|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.follow(list_member.id, :include_entities => false)
          end
        end
        say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
        say
        say "Run `#{File.basename($0)} unfollow all listed #{list_name}` to stop."
      end

      desc "users SCREEN_NAME [SCREEN_NAME...]", "Allows you to start following users."
      def users(screen_name, *screen_names)
        screen_names.unshift(screen_name)
        screen_names.threaded_map do |screen_name|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.follow(screen_name, :include_entities => false)
          end
        end
        number = screen_names.length
        say "@#{@rcfile.default_profile[0]} is now following #{number} more #{number == 1 ? 'user' : 'users'}."
        say
        say "Run `#{File.basename($0)} unfollow users #{screen_names.join(' ')}` to stop."
      end

    end
  end
end
