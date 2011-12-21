require 't/core_ext/enumerable'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List
      class Remove
        class All < Thor
          DEFAULT_HOST = 'api.twitter.com'
          DEFAULT_PROTOCOL = 'https'

          check_unknown_options!

          def initialize(*)
            super
            @rcfile = RCFile.instance
          end

          desc "friends LIST_NAME", "Remove all friends from a list."
          def friends(list_name)
            list_member_ids = []
            cursor = -1
            until cursor == 0
              list_members = client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
              list_member_ids += list_members.users.collect{|user| user.id}
              cursor = list_members.next_cursor
            end
            friend_ids = []
            cursor = -1
            until cursor == 0
              friends = client.friend_ids(:cursor => cursor)
              friend_ids += friends.ids
              cursor = friends.next_cursor
            end
            list_member_ids_to_remove = (friend_ids - list_member_ids)
            number = list_member_ids_to_remove.length
            if number.zero?
              return say "None of @#{@rcfile.default_profile[0]}'s friends are members of the list \"#{list_name}\"."
            else
              return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'friend' : 'friends'} from the list \"#{list_name}\"?"
            end
            list_member_ids_to_remove.threaded_map do |list_member_id|
              client.list_remove_member(list_name, list_member_id)
            end
            say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'friend' : 'friends'} from the list \"#{list_name}\"."
            say
            say "Run `#{$0} list add all friends #{list_name}` to undo."
          end

          desc "followers LIST_NAME", "Remove all followers from a list."
          def followers(list_name)
            list_member_ids = []
            cursor = -1
            until cursor == 0
              list_members = client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
              list_member_ids += list_members.users.collect{|user| user.id}
              cursor = list_members.next_cursor
            end
            follower_ids = []
            cursor = -1
            until cursor == 0
              followers = client.follower_ids(:cursor => cursor)
              follower_ids += followers.ids
              cursor = followers.next_cursor
            end
            list_member_ids_to_remove = (follower_ids - list_member_ids)
            number = list_member_ids_to_remove.length
            if number.zero?
              return say "None of @#{@rcfile.default_profile[0]}'s followers are members of the list \"#{list_name}\"."
            else
              return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'follower' : 'followers'} from the list \"#{list_name}\"?"
            end
            list_member_ids_to_remove.threaded_map do |list_member_id|
              client.list_remove_member(list_name, list_member_id)
            end
            say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'follower' : 'followers'} from the list \"#{list_name}\"."
            say
            say "Run `#{$0} list add all followers #{list_name}` to undo."
          end

          desc "listed FROM_LIST_NAME TO_LIST_NAME", "Remove all list members from a list."
          def listed(from_list_name, to_list_name)
            to_list_member_ids = []
            cursor = -1
            until cursor == 0
              list_members = client.list_members(to_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
              to_list_member_ids += list_members.users.collect{|user| user.id}
              cursor = list_members.next_cursor
            end
            from_list_member_ids = []
            cursor = -1
            until cursor == 0
              list_members = client.list_members(from_list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
              from_list_member_ids += list_members.users.collect{|user| user.id}
              cursor = list_members.next_cursor
            end
            list_member_ids_to_remove = (from_list_member_ids - to_list_member_ids)
            number = list_member_ids_to_remove.length
            if number.zero?
              return say "None of the members of the list \"#{from_list_name}\" are members of the list \"#{to_list_name}\"."
            else
              return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{to_list_name}\"?"
            end
            list_member_ids_to_remove.threaded_map do |list_member_id|
              client.list_remove_member(to_list_name, list_member_id)
            end
            say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{to_list_name}\"."
            say
            say "Run `#{$0} list add all listed #{from_list_name} #{to_list_name}` to undo."
          end

          desc "members LIST_NAME", "Remove all members from a list."
          def members(list_name)
            list_member_ids = []
            cursor = -1
            until cursor == 0
              list_members = client.list_members(list_name, :cursor => cursor, :skip_status => true, :include_entities => false)
              list_member_ids += list_members.users.collect{|user| user.id}
              cursor = list_members.next_cursor
            end
            number = list_member_ids.length
            return say "The list \"#{list_name}\" doesn't have any members." if number.zero?
            return unless yes? "Are you sure you want to remove #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list_name}\"?"
            list_member_ids.threaded_map do |list_member_id|
              client.list_remove_member(list_name, list_member_id)
            end
            say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list_name}\"."
          end
          map %w(users) => :members

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
end
