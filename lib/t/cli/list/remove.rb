require 'active_support/core_ext/array/grouping'
require 't/core_ext/string'
require 't/collectable'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List
      class Remove < Thor
        include T::Collectable

        DEFAULT_HOST = 'api.twitter.com'
        DEFAULT_PROTOCOL = 'https'

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "friends LIST_NAME", "Remove all friends from a list."
        def friends(list_name)
          list_member_ids = collect_with_cursor do |cursor|
            client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          friend_ids = collect_with_cursor do |cursor|
            client.friend_ids(:cursor => cursor)
          end
          list_member_ids_to_remove = (friend_ids - list_member_ids)
          number = list_member_ids_to_remove.length
          if number.zero?
            return say "None of @#{@rcfile.default_profile[0]}'s friends are members of the list \"#{list_name}\"."
          else
            return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'friend' : 'friends'} from the list \"#{list_name}\"?"
          end
          list_member_ids_to_remove.in_groups_of(100, false) do |user_id_group|
            client.list_remove_members(list_name, user_id_group)
          end
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'friend' : 'friends'} from the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list add all friends #{list_name}` to undo."
        end

        desc "followers LIST_NAME", "Remove all followers from a list."
        def followers(list_name)
          list_member_ids = collect_with_cursor do |cursor|
            client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          follower_ids = collect_with_cursor do |cursor|
            client.follower_ids(:cursor => cursor)
          end
          list_member_ids_to_remove = (follower_ids - list_member_ids)
          number = list_member_ids_to_remove.length
          if number.zero?
            return say "None of @#{@rcfile.default_profile[0]}'s followers are members of the list \"#{list_name}\"."
          else
            return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'follower' : 'followers'} from the list \"#{list_name}\"?"
          end
          list_member_ids_to_remove.in_groups_of(100, false) do |user_id_group|
            client.list_remove_members(list_name, user_id_group)
          end
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'follower' : 'followers'} from the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list add all followers #{list_name}` to undo."
        end

        desc "listed FROM_LIST_NAME TO_LIST_NAME", "Remove all list members from a list."
        def listed(from_list_name, to_list_name)
          to_list_members = collect_with_cursor do |cursor|
            client.list_members(to_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          from_list_members = collect_with_cursor do |cursor|
            client.list_members(from_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          list_member_ids_to_remove = (from_list_members.collect(&:id) - to_list_members.collect(&:id))
          number = list_member_ids_to_remove.length
          if number.zero?
            return say "None of the members of the list \"#{from_list_name}\" are members of the list \"#{to_list_name}\"."
          else
            return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{to_list_name}\"?"
          end
          list_member_ids_to_remove.in_groups_of(100, false) do |user_id_group|
            client.list_remove_members(to_list_name, user_id_group)
          end
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{to_list_name}\"."
          say
          say "Run `#{File.basename($0)} list add all listed #{from_list_name} #{to_list_name}` to undo."
        end

        desc "members LIST_NAME", "Remove all members from a list."
        def members(list_name)
          list_members = collect_with_cursor do |cursor|
            client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          number = list_members.length
          return say "The list \"#{list_name}\" doesn't have any members." if number.zero?
          return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list_name}\"?"
          list_members.collect(&:id).in_groups_of(100, false) do |user_id_group|
            client.list_remove_members(list_name, user_id_group)
          end
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list_name}\"."
        end
        map %w(all) => :members

        desc "users LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Remove users from a list."
        def users(list_name, screen_name, *screen_names)
          screen_names.unshift(screen_name)
          screen_names.map!(&:strip_at)
          screen_names.in_groups_of(100, false) do |user_id_group|
            client.list_remove_members(list_name, user_id_group)
          end
          number = screen_names.length
          say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'user' : 'users'} from the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list add users #{list_name} #{screen_names.join(' ')}` to undo."
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
