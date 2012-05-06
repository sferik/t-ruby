require 't/printable'
require 't/rcfile'
require 't/search'
require 'thor'
require 'tweetstream'

module T
  class Stream < Thor
    include T::Printable

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "all", "Stream a random sample of all Tweets (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def all
      if options['csv']
        say STATUS_HEADINGS.to_csv
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        else
          print_status(status)
        end
      end
      until_term
      client.sample
    end

    desc "matrix", "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."
    def matrix
      client.on_timeline_status do |status|
        say(status.text.gsub("\n", ''), [:bold, :green, :on_black])
      end
      until_term
      client.sample
    end

    desc "search KEYWORD [KEYWORD...]", "Stream Tweets that contain specified keywords, joined with logical ORs (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def search(keyword, *keywords)
      keywords.unshift(keyword)
      client.on_inited do
        search = T::Search.new
        search.options = search.options.merge(options)
        search.options = search.options.merge(:reverse => true)
        search.all(keywords.join(' OR '))
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        else
          print_status(status)
        end
      end
      until_term
      client.track(keywords)
    end

    desc "timeline", "Stream your timeline (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def timeline
      client.on_inited do
        cli = T::CLI.new
        cli.options = cli.options.merge(options)
        cli.options = cli.options.merge(:reverse => true)
        cli.timeline
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        else
          print_status(status)
        end
      end
      until_term
      client.userstream
    end

    desc "users SCREEN_NAME [SCREEN_NAME...]", "Stream Tweets either from or in reply to specified users (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    def users(screen_name, *screen_names)
      if options['csv']
        say STATUS_HEADINGS.to_csv
      end
      screen_names.unshift(screen_name)
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        else
          print_status(status)
        end
      end
      until_term
      client.follow(screen_names)
    end

  private

    def client
      return @client if @client
      @rcfile.path = options['profile'] if options['profile']
      @client = TweetStream::Client.new(
        :consumer_key => @rcfile.active_consumer_key,
        :consumer_secret => @rcfile.active_consumer_secret,
        :oauth_token => @rcfile.active_token,
        :oauth_token_secret => @rcfile.active_secret
      )
    end

    def until_term
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
    end

  end
end
