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

    desc "add LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Add members to a list."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def add(list_name, screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.map!(&:strip_ats)
      screen_names.map!(&:to_i) if options['id']
      screen_names.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.list_add_members(list_name, user_id_group)
        end
      end
      number = screen_names.length
      say "@#{@rcfile.default_profile[0]} added #{number} #{number == 1 ? 'member' : 'members'} to the list \"#{list_name}\"."
      say
      say "Run `#{File.basename($0)} list remove #{list_name} #{screen_names.join(' ')}` to undo."
    end

    desc "create LIST_NAME [DESCRIPTION]", "Create a new list."
    method_option :private, :aliases => "-p", :type => :boolean
    def create(list_name, description="")
      opts = description.blank? ? {} : {:description => description}
      opts.merge!(:mode => 'private') if options['private']
      client.list_create(list_name, opts)
      say "@#{@rcfile.default_profile[0]} created the list \"#{list_name}\"."
    end

    desc "members [SCREEN_NAME] LIST_NAME", "Returns the members of a Twitter list."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as a Twitter user ID instead of a screen name."
    method_option :listed, :aliases => "-s", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def members(*args)
      list = args.pop
      owner = args.pop || @rcfile.default_profile[0]
      owner = owner.strip_ats
      owner = owner.to_i if options['id']
      users = collect_with_cursor do |cursor|
        client.list_members(owner, list, :cursor => cursor, :include_entities => false, :skip_status => true)
      end
      print_user_list(users)
    end

    desc "remove LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Remove members from a list."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def remove(list_name, screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.map!(&:strip_ats)
      screen_names.map!(&:to_i) if options['id']
      screen_names.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.list_remove_members(list_name, user_id_group)
        end
      end
      number = screen_names.length
      say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'member' : 'members'} from the list \"#{list_name}\"."
      say
      say "Run `#{File.basename($0)} list add #{list_name} #{screen_names.join(' ')}` to undo."
    end

    desc "timeline [SCREEN_NAME] LIST_NAME", "Show tweet timeline for members of the specified list."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as a Twitter user ID instead of a screen name."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def timeline(*args)
      list = args.pop
      owner = args.pop || @rcfile.default_profile[0]
      owner = owner.strip_ats
      owner = owner.to_i if options['id']
      per_page = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.list_timeline(owner, list, :include_entities => false, :per_page => per_page)
      print_status_list(statuses)
    end
    map %w(tl) => :timeline

  end
end
