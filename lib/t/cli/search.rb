require 'action_view'
require 'pager'
require 'retryable'
require 't/core_ext/enumerable'
require 't/rcfile'
require 't/requestable'
require 'thor'

module T
  class CLI
    class Search < Thor
      include ActionView::Helpers::DateHelper
      include Pager
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
      method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
      def all(query)
        defaults = {:include_entities => false}
        defaults.merge!(:rpp => options['number']) if options['number']
        timeline = client.search(query, defaults)
        timeline.reverse! if options['reverse']
        page unless T.env.test?
        timeline.each do |status|
          say "#{status.from_user.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end

      desc "favorites QUERY", "Returns Tweets you've favorited that mach a specified query."
      def favorites(query)
        timeline = 1.upto(MAX_PAGES).threaded_map do |page|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.favorites(:page => page, :count => MAX_NUM_RESULTS).select do |status|
              /#{query}/i.match(status.text)
            end
          end
        end
        page unless T.env.test?
        timeline.flatten.compact.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
      map %w(faves) => :favorites

      desc "retweets QUERY", "Returns Tweets you've retweeted that mach a specified query."
      def retweets(query)
        timeline = 1.upto(MAX_PAGES).threaded_map do |page|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.retweeted_by(:page => page, :count => MAX_NUM_RESULTS).select do |status|
              /#{query}/i.match(status.text)
            end
          end
        end
        page unless T.env.test?
        timeline.flatten.compact.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
      map %w(rts) => :retweets

      desc "timeline QUERY", "Returns Tweets in your timeline that match a specified query."
      def timeline(query)
        timeline = 1.upto(MAX_PAGES).threaded_map do |page|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.home_timeline(:page => page, :count => MAX_NUM_RESULTS).select do |status|
              /#{query}/i.match(status.text)
            end
          end
        end
        page unless T.env.test?
        timeline.flatten.compact.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
      map %w(tl) => :timeline

      desc "user SCREEN_NAME QUERY", "Returns Tweets in a user's timeline that match a specified query."
      def user(screen_name, query)
        screen_name = screen_name.strip_at
        timeline = 1.upto(MAX_PAGES).threaded_map do |page|
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            client.user_timeline(screen_name, :page => page, :count => MAX_NUM_RESULTS).select do |status|
              /#{query}/i.match(status.text)
            end
          end
        end
        page unless T.env.test?
        timeline.flatten.compact.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end

    end
  end
end
