require 'action_view'
require 'active_support/core_ext/array/grouping'
require 'retryable'
require 't/collectable'
require 't/core_ext/enumerable'
require 't/core_ext/string'
require 't/printable'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class List < Thor
    include ActionView::Helpers::DateHelper
    include T::Collectable
    include T::Printable
    include T::Requestable

    DEFAULT_NUM_RESULTS = 20
    MAX_SCREEN_NAME_SIZE = 20
    MAX_USERS_PER_LIST = 500
    MAX_USERS_PER_REQUEST = 100

    check_unknown_options!

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "add LIST USER [USER...]", "Add members to a list."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def add(list, user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.list_add_members(list, user_id_group)
        end
      end
      number = users.length
      say "@#{@rcfile.default_profile[0]} added #{number} #{number == 1 ? 'member' : 'members'} to the list \"#{list}\"."
      say
      if options['id']
        say "Run `#{File.basename($0)} list remove --id #{list} #{users.join(' ')}` to undo."
      else
        say "Run `#{File.basename($0)} list remove #{list} #{users.map{|user| "@#{user}"}.join(' ')}` to undo."
      end
    end

    desc "create LIST [DESCRIPTION]", "Create a new list."
    method_option :private, :aliases => "-p", :type => :boolean
    def create(list, description="")
      opts = description.blank? ? {} : {:description => description}
      opts.merge!(:mode => 'private') if options['private']
      client.list_create(list, opts)
      say "@#{@rcfile.default_profile[0]} created the list \"#{list}\"."
    end

    desc "members [USER/]LIST", "Returns the members of a Twitter list."
    method_option :csv, :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :friends, :aliases => "-e", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option :listed, :aliases => "-s", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option :posted, :aliases => "-p", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was posted."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def members(list)
      owner, list = list.split('/')
      if list.nil?
        list = owner
        owner = @rcfile.default_profile[0]
      else
        owner = if options['id']
          owner.to_i
        else
          owner.strip_ats
        end
      end
      users = collect_with_cursor do |cursor|
        client.list_members(owner, list, :cursor => cursor, :include_entities => false, :skip_status => true)
      end
      print_user_list(users)
    end

    desc "remove LIST USER [USER...]", "Remove members from a list."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def remove(list, user, *users)
      users.unshift(user)
      if options['id']
        users.map!(&:to_i)
      else
        users.map!(&:strip_ats)
      end
      users.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.list_remove_members(list, user_id_group)
        end
      end
      number = users.length
      say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list}\"."
      say
      if options['id']
        say "Run `#{File.basename($0)} list add --id #{list} #{users.join(' ')}` to undo."
      else
        say "Run `#{File.basename($0)} list add #{list} #{users.map{|user| "@#{user}"}.join(' ')}` to undo."
      end
    end

    desc "timeline [USER/]LIST", "Show tweet timeline for members of the specified list."
    method_option :csv, :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify user via ID instead of screen name."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def timeline(list)
      owner, list = list.split('/')
      if list.nil?
        list = owner
        owner = @rcfile.default_profile[0]
      else
        owner = if options['id']
          owner.to_i
        else
          owner.strip_ats
        end
      end
      per_page = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.list_timeline(owner, list, :include_entities => false, :per_page => per_page)
      print_status_list(statuses)
    end
    map %w(tl) => :timeline

  end
end
