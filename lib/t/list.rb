require 'action_view'
require 'active_support/core_ext/array/grouping'
require 'retryable'
require 't/core_ext/enumerable'
require 't/core_ext/string'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class List < Thor
    include ActionView::Helpers::DateHelper
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

    desc "add LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Add users to a list."
    def add(list_name, screen_name, *screen_names)
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

    desc "create LIST_NAME [DESCRIPTION]", "Create a new list."
    method_option :private, :aliases => "-p", :type => :boolean
    def create(list_name, description="")
      opts = description.blank? ? {} : {:description => description}
      opts.merge!(:mode => 'private') if options['private']
      client.list_create(list_name, opts)
      say "@#{@rcfile.default_profile[0]} created the list \"#{list_name}\"."
    end

    # Remove
    desc "remove LIST_NAME SCREEN_NAME [SCREEN_NAME...]", "Remove users from a list."
    def remove(list_name, screen_name, *screen_names)
      screen_names.unshift(screen_name)
      screen_names.map!(&:strip_at)
      screen_names.in_groups_of(MAX_USERS_PER_REQUEST, false).threaded_each do |user_id_group|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.list_remove_members(list_name, user_id_group)
        end
      end
      number = screen_names.length
      say "@#{@rcfile.default_profile[0]} removed #{number} #{number == 1 ? 'user' : 'users'} from the list \"#{list_name}\"."
      say
      say "Run `#{File.basename($0)} list add users #{list_name} #{screen_names.join(' ')}` to undo."
    end

    desc "timeline [SCREEN_NAME] LIST_NAME", "Show tweet timeline for members of the specified list."
    method_option :created, :aliases => "-c", :type => :boolean, :default => false, :desc => "Sort by the time when Twitter acount was created."
    method_option :friends, :aliases => "-d", :type => :boolean, :default => false, :desc => "Sort by total number of friends."
    method_option :followers, :aliases => "-f", :type => :boolean, :default => false, :desc => "Sort by total number of followers."
    method_option :listed, :aliases => "-i", :type => :boolean, :default => false, :desc => "Sort by number of list memberships."
    method_option :long, :aliases => "-l", :type => :boolean, :default => false, :desc => "List in long format."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    method_option :reverse, :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option :tweets, :aliases => "-t", :type => :boolean, :default => false, :desc => "Sort by total number of Tweets."
    method_option :unsorted, :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    method_option :favorites, :aliases => "-v", :type => :boolean, :default => false, :desc => "Sort by total number of favorites."
    def timeline(*args)
      list = args.pop
      owner = args.pop || @rcfile.default_profile[0]
      per_page = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.list_timeline(owner, list, :include_entities => false, :per_page => per_page)
      statuses.reverse! if options['reverse']
      if options['long']
        array = statuses.map do |status|
          created_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
          [status.id.to_s, created_at, status.user.screen_name, status.text.gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Created at", "Screen name", "Text"]
          array.unshift(headings)
        end
        print_table(array)
      else
        statuses.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
    end
    map %w(tl) => :timeline

  end
end
