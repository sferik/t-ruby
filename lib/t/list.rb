require 'thor'
require 'twitter'
require 't/collectable'
require 't/printable'
require 't/rcfile'
require 't/requestable'
require 't/utils'

module T
  class List < Thor
    include T::Collectable
    include T::Printable
    include T::Requestable
    include T::Utils

    DEFAULT_NUM_RESULTS = 20
    MAX_USERS_PER_LIST = 500
    MAX_USERS_PER_REQUEST = 100

    check_unknown_options!

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
    end

    desc "add LIST USER [USER...]", "Add members to a list."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def add(list, user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.list_add_members(list, users)
        users
      end
      say "@#{@rcfile.active_profile[0]} added #{pluralize(number, 'member')} to the list \"#{list}\"."
      say
      if options['id']
        say "Run `#{File.basename($0)} list remove --id #{list} #{users.join(' ')}` to undo."
      else
        say "Run `#{File.basename($0)} list remove #{list} #{users.map{|user| "@#{user}"}.join(' ')}` to undo."
      end
    end

    desc "create LIST [DESCRIPTION]", "Create a new list."
    method_option "private", :aliases => "-p", :type => :boolean
    def create(list, description=nil)
      opts = description ? {:description => description} : {}
      opts.merge!(:mode => 'private') if options['private']
      client.list_create(list, opts)
      say "@#{@rcfile.active_profile[0]} created the list \"#{list}\"."
    end

    desc "information [USER/]LIST", "Retrieves detailed information about a Twitter list."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def information(list)
      owner, list = extract_owner(list, options)
      list = client.list(owner, list)
      if options['csv']
        require 'csv'
        say ["ID", "Description", "Slug", "Screen name", "Created at", "Members", "Subscribers", "Following", "Mode", "URL"].to_csv
        say [list.id, list.description, list.slug, list.user.screen_name, csv_formatted_time(list), list.member_count, list.subscriber_count, list.following?, list.mode, list.uri].to_csv
      else
        array = []
        array << ["ID", list.id.to_s]
        array << ["Description", list.description] unless list.description.nil?
        array << ["Slug", list.slug]
        array << ["Screen name", "@#{list.user.screen_name}"]
        array << ["Created at", "#{ls_formatted_time(list)} (#{time_ago_in_words(list.created_at)} ago)"]
        array << ["Members", number_with_delimiter(list.member_count)]
        array << ["Subscribers", number_with_delimiter(list.subscriber_count)]
        array << ["Status", list.following ? "Following" : "Not following"]
        array << ["Mode", list.mode]
        array << ["URL", list.uri]
        print_table(array)
      end
    end
    map %w(details) => :information

    desc "members [USER/]LIST", "Returns the members of a Twitter list."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    method_option "sort", :aliases => "-s", :type => :string, :enum => %w(favorites followers friends listed screen_name since tweets tweeted), :default => "screen_name", :desc => "Specify the order of the results.", :banner => "ORDER"
    method_option "unsorted", :aliases => "-u", :type => :boolean, :default => false, :desc => "Output is not sorted."
    def members(list)
      owner, list = extract_owner(list, options)
      users = client.list_members(owner, list).to_a
      print_users(users)
    end

    desc "remove LIST USER [USER...]", "Remove members from a list."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def remove(list, user, *users)
      users, number = fetch_users(users.unshift(user), options) do |users|
        client.list_remove_members(list, users)
        users
      end
      say "@#{@rcfile.active_profile[0]} removed #{pluralize(number, 'member')} from the list \"#{list}\"."
      say
      if options['id']
        say "Run `#{File.basename($0)} list add --id #{list} #{users.join(' ')}` to undo."
      else
        say "Run `#{File.basename($0)} list add #{list} #{users.map{|user| "@#{user}"}.join(' ')}` to undo."
      end
    end

    desc "timeline [USER/]LIST", "Show tweet timeline for members of the specified list."
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "id", :aliases => "-i", :type => :boolean, :default => false, :desc => "Specify user via ID instead of screen name."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    method_option "number", :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS, :desc => "Limit the number of results."
    method_option "reverse", :aliases => "-r", :type => :boolean, :default => false, :desc => "Reverse the order of the sort."
    def timeline(list)
      owner, list = extract_owner(list, options)
      count = options['number'] || DEFAULT_NUM_RESULTS
      tweets = collect_with_count(count) do |count_opts|
        client.list_timeline(owner, list, count_opts)
      end
      print_tweets(tweets)
    end
    map %w(tl) => :timeline

  end
end
