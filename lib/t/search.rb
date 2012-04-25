require 'action_view'
require 'retryable'
require 't/core_ext/enumerable'
require 't/printable'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class Search < Thor
    include ActionView::Helpers::DateHelper
    include T::Printable
    include T::Requestable

    DEFAULT_NUM_RESULTS = 20
    MAX_PAGES = 16
    MAX_NUM_RESULTS = 200
    MAX_SCREEN_NAME_SIZE = 20

    check_unknown_options!

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "all QUERY", "Returns the #{DEFAULT_NUM_RESULTS} most recent Tweets that match a specified query."
    method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
    def all(query)
      rpp = options['number'] || DEFAULT_NUM_RESULTS
      statuses = client.search(query, :include_entities => false, :rpp => rpp)
      if options['long']
        array = statuses.map do |status|
          created_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
          [status.id.to_s, created_at, "@#{status.from_user}", status.text.gsub(/\n+/, ' ')]
        end
        if STDOUT.tty?
          headings = ["ID", "Posted at", "Screen name", "Text"]
          array.unshift(headings) unless statuses.empty?
        end
        print_table(array)
      else
        statuses.each do |status|
          say "#{status.from_user.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
    end

    desc "favorites QUERY", "Returns Tweets you've favorited that mach a specified query."
    def favorites(query)
      statuses = 1.upto(MAX_PAGES).threaded_map do |page|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.favorites(:page => page, :count => MAX_NUM_RESULTS).select do |status|
            /#{query}/i.match(status.text)
          end
        end
      end.flatten.compact
      print_status_list(statuses)
    end
    map %w(faves) => :favorites

    desc "mentions QUERY", "Returns Tweets mentioning you that mach a specified query."
    def mentions(query)
      statuses = 1.upto(MAX_PAGES).threaded_map do |page|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.mentions(:page => page, :count => MAX_NUM_RESULTS).select do |status|
            /#{query}/i.match(status.text)
          end
        end
      end.flatten.compact
      print_status_list(statuses)
    end
    map %w(replies) => :mentions

    desc "retweets QUERY", "Returns Tweets you've retweeted that mach a specified query."
    def retweets(query)
      statuses = 1.upto(MAX_PAGES).threaded_map do |page|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.retweeted_by(:page => page, :count => MAX_NUM_RESULTS).select do |status|
            /#{query}/i.match(status.text)
          end
        end
      end.flatten.compact
      print_status_list(statuses)
    end
    map %w(rts) => :retweets

    desc "timeline QUERY", "Returns Tweets in your timeline that match a specified query."
    def timeline(query)
      statuses = 1.upto(MAX_PAGES).threaded_map do |page|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.home_timeline(:page => page, :count => MAX_NUM_RESULTS).select do |status|
            /#{query}/i.match(status.text)
          end
        end
      end.flatten.compact
      print_status_list(statuses)
    end
    map %w(tl) => :timeline

    desc "user SCREEN_NAME QUERY", "Returns Tweets in a user's timeline that match a specified query."
    method_option :id, :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    def user(screen_name, query)
      screen_name = screen_name.strip_ats
      screen_name = screen_name.to_i if options['id']
      statuses = 1.upto(MAX_PAGES).threaded_map do |page|
        retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
          client.user_timeline(screen_name, :page => page, :count => MAX_NUM_RESULTS).select do |status|
            /#{query}/i.match(status.text)
          end
        end
      end.flatten.compact
      print_status_list(statuses)
    end

  end
end
