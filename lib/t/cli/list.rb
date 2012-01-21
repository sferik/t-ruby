require 'action_view'
require 'pager'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List < Thor
      include ActionView::Helpers::DateHelper
      include Pager

      DEFAULT_HOST = 'api.twitter.com'
      DEFAULT_PROTOCOL = 'https'
      DEFAULT_NUM_RESULTS = 20
      MAX_SCREEN_NAME_SIZE = 20

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "create LIST_NAME [DESCRIPTION]", "Create a new list."
      method_option :private, :aliases => "-p", :type => :boolean
      def create(list_name, description="")
        defaults = description.blank? ? {} : {:description => description}
        defaults.merge!(:mode => 'private') if options['private']
        client.list_create(list_name, defaults)
        say "@#{@rcfile.default_profile[0]} created the list \"#{list_name}\"."
      end

      desc "timeline LIST_NAME", "Show tweet timeline for members of the specified list."
      method_option :number, :aliases => "-n", :type => :numeric, :default => DEFAULT_NUM_RESULTS
      method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
      def timeline(list_name)
        defaults = {:include_entities => false}
        defaults.merge!(:per_page => options['number']) if options['number']
        timeline = client.list_timeline(list_name, defaults)
        timeline.reverse! if options['reverse']
        page unless ENV["T_ENV"] == "test"
        timeline.each do |status|
          say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
        end
      end
      map %w(tl) => :timeline

      desc "add SUBCOMMAND ...ARGS", "Add users to a list."
      require 't/cli/list/add'
      subcommand 'add', CLI::List::Add

      desc "remove SUBCOMMAND ...ARGS", "Remove users from a list."
      require 't/cli/list/remove'
      subcommand 'remove', CLI::List::Remove

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
