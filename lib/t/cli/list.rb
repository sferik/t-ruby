require 'action_view'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List < Thor
      include ActionView::Helpers::DateHelper

      DEFAULT_HOST = 'api.twitter.com'
      DEFAULT_PROTOCOL = 'https'

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "create LISTNAME [DESCRIPTION]", "Create a new list."
      method_option :private, :aliases => "-p", :type => :boolean
      def create(listname, description="")
        hash = description.blank? ? {} : {:description => description}
        hash.merge!(:mode => 'private') if options['private']
        list = client.list_create(listname, hash)
        say "@#{@rcfile.default_profile[0]} created the list: #{list.name}."
      end

      desc "timeline LISTNAME", "Show tweet timeline for members of the specified list."
      method_option :number, :aliases => "-n", :type => :numeric, :default => 20
      method_option :reverse, :aliases => "-r", :type => :boolean, :default => false
      def timeline(listname)
        hash = {}
        hash.merge!(:per_page => options['number']) if options['number']
        timeline = client.list_timeline(listname, hash)
        timeline.reverse! if options['reverse']
        run_pager
        timeline.map do |status|
          say "#{status.user.screen_name.rjust(20)}: #{status.text} (#{time_ago_in_words(status.created_at)} ago)"
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

      def run_pager
        return if RUBY_PLATFORM =~ /win32/
        return if ENV["T_ENV"] == "test"
        return unless STDOUT.tty?

        read, write = IO.pipe

        unless Kernel.fork # Child process
          STDOUT.reopen(write)
          STDERR.reopen(write) if STDERR.tty?
          read.close
          write.close
          return
        end

        # Parent process, become pager
        STDIN.reopen(read)
        read.close
        write.close

        ENV['LESS'] = 'FSRX' # Don't page if the input is short enough

        Kernel.select [STDIN] # Wait until we have input before we start the pager
        pager = ENV['PAGER'] || 'less'
        exec pager rescue exec "/bin/sh", "-c", pager
      end

    end
  end
end
