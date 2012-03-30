require 'active_support/core_ext/array/grouping'
require 'retryable'
require 't/core_ext/enumerable'
require 't/core_ext/string'
require 't/collectable'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class CLI
    class List
      class Add < Thor
        include T::Collectable
        include T::Requestable

        MAX_USERS_PER_LIST = 500
        MAX_USERS_PER_REQUEST = 100

        check_unknown_options!

        def initialize(*)
          super
          @rcfile = RCFile.instance
        end

        desc "friends LIST_NAME", "Add all friends to a list."
        def friends(list_name)
          list_member_ids = collect_with_cursor do |cursor|
            client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          existing_list_members = list_member_ids.length
          if existing_list_members >= MAX_USERS_PER_LIST
            return say "The list \"#{list_name}\" are already contains the maximum of #{MAX_USERS_PER_LIST} members."
          end
          friend_ids = collect_with_cursor do |cursor|
            client.friend_ids(:cursor => cursor)
          end
          list_member_ids_to_add = (friend_ids - list_member_ids)
          number = list_member_ids_to_add.length
          if number.zero?
            return say "All of @#{@rcfile.default_profile[0]}'s friends are already members of the list \"#{list_name}\"."
          elsif existing_list_members + number > MAX_USERS_PER_LIST
            return unless yes? "Lists can't have more than #{MAX_USERS_PER_LIST} members. Do you want to add up to #{MAX_USERS_PER_LIST} friends to the list \"#{list_name}\"?"
          else
            return unless yes? "Are you sure you want to add #{number} #{number == 1 ? 'friend' : 'friends'} to the list \"#{list_name}\"?"
          end
          max_members_to_add = MAX_USERS_PER_LIST - existing_list_members
          list_member_ids_to_add[0...max_members_to_add].in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
            retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
              client.list_add_members(list_name, user_id_group)
            end
          end
          number_added = [number, max_members_to_add].min
          say "@#{@rcfile.default_profile[0]} added #{number_added} #{number_added == 1 ? 'friend' : 'friends'} to the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list remove all friends #{list_name}` to undo."
        end

        desc "followers LIST_NAME", "Add all followers to a list."
        def followers(list_name)
          list_member_ids = collect_with_cursor do |cursor|
            client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          existing_list_members = list_member_ids.length
          if existing_list_members >= MAX_USERS_PER_LIST
            return say "The list \"#{list_name}\" are already contains the maximum of #{MAX_USERS_PER_LIST} members."
          end
          follower_ids = collect_with_cursor do |cursor|
            followers = client.follower_ids(:cursor => cursor)
          end
          list_member_ids_to_add = (follower_ids - list_member_ids)
          number = list_member_ids_to_add.length
          if number.zero?
            return say "All of @#{@rcfile.default_profile[0]}'s followers are already members of the list \"#{list_name}\"."
          elsif existing_list_members + number > MAX_USERS_PER_LIST
            return unless yes? "Lists can't have more than #{MAX_USERS_PER_LIST} members. Do you want to add up to #{MAX_USERS_PER_LIST} followers to the list \"#{list_name}\"?"
          else
            return unless yes? "Are you sure you want to add #{number} #{number == 1 ? 'follower' : 'followers'} to the list \"#{list_name}\"?"
          end
          max_members_to_add = MAX_USERS_PER_LIST - existing_list_members
          list_member_ids_to_add[0...max_members_to_add].in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
            retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
              client.list_add_members(list_name, user_id_group)
            end
          end
          number_added = [number, max_members_to_add].min
          say "@#{@rcfile.default_profile[0]} added #{number_added} #{number_added == 1 ? 'follower' : 'followers'} to the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list remove all followers #{list_name}` to undo."
        end

        desc "listed FROM_LIST_NAME TO_LIST_NAME", "Add all list memebers to a list."
        def listed(from_list_name, to_list_name)
          to_list_members = collect_with_cursor do |cursor|
            client.list_members(to_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          existing_list_members = to_list_members.length
          if existing_list_members >= MAX_USERS_PER_LIST
            return say "The list \"#{to_list_name}\" are already contains the maximum of #{MAX_USERS_PER_LIST} members."
          end
          from_list_members = collect_with_cursor do |cursor|
            client.list_members(from_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
          end
          list_member_ids_to_add = (from_list_members.collect(&:id) - to_list_members.collect(&:id))
          number = list_member_ids_to_add.length
          if number.zero?
            return say "All of the members of the list \"#{from_list_name}\" are already members of the list \"#{to_list_name}\"."
          elsif existing_list_members + number > MAX_USERS_PER_LIST
            return unless yes? "Lists can't have more than #{MAX_USERS_PER_LIST} members. Do you want to add up to #{MAX_USERS_PER_LIST} members to the list \"#{to_list_name}\"?"
          else
            return unless yes? "Are you sure you want to add #{number} #{number == 1 ? 'member' : 'members'} to the list \"#{to_list_name}\"?"
          end
          max_members_to_add = MAX_USERS_PER_LIST - existing_list_members
          list_member_ids_to_add[0...max_members_to_add].in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
            retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
              client.list_add_members(to_list_name, user_id_group)
            end
          end
          number_added = [number, max_members_to_add].min
          say "@#{@rcfile.default_profile[0]} added #{number_added} #{number_added == 1 ? 'member' : 'members'} to the list \"#{to_list_name}\"."
          say
          say "Run `#{File.basename($0)} list remove all listed #{from_list_name} #{to_list_name}` to undo."
        end

        desc "users LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Add users to a list."
        def users(list_name, screen_name, *screen_names)
          screen_names.unshift(screen_name)
          screen_names.map!(&:strip_at)
          screen_names.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
            retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
              client.list_add_members(list_name, user_id_group)
            end
          end
          number = screen_names.length
          say "@#{@rcfile.default_profile[0]} added #{number} #{number == 1 ? 'user' : 'users'} to the list \"#{list_name}\"."
          say
          say "Run `#{File.basename($0)} list remove users #{list_name} #{screen_names.join(' ')}` to undo."
        end

      end
    end
  end
end
