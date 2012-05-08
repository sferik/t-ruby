require 't/cli'
require 't/printable'
require 't/rcfile'
require 't/search'
require 'thor'
require 'tweetstream'

module T
  class Stream < Thor
    include T::Printable

    STATUS_HEADINGS_FORMATTING = [
      "%-18s",  # Add padding to maximum length of a Tweet ID
      "%-12s",  # Add padding to length of a timestamp formatted with ls_formatted_time
      "%-20s",  # Add padding to maximum length of a Twitter screen name
      "%s",     # Last element does not need special formatting
    ]

    def initialize(*)
      super
      @rcfile = RCFile.instance
    end

    desc "all", "Stream a random sample of all Tweets (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def all
      client.on_inited do
        if options['csv']
          say STATUS_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          say STATUS_HEADINGS.size.times.map do |index|
            STATUS_HEADINGS_FORMATTING[index] % STATUS_HEADINGS[index]
          end
        end
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        elsif options['long']
          print_table build_long_status(status).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
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
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def search(keyword, *keywords)
      keywords.unshift(keyword)
      client.on_inited do
        search = T::Search.new
        search.options = search.options.merge(options)
        search.options = search.options.merge(:reverse => true)
        search.options = search.options.merge(:format => STATUS_HEADINGS_FORMATTING)
        search.all(keywords.join(' OR '))
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        elsif options['long']
          print_table build_long_status(status).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
        else
          print_status(status)
        end
      end
      until_term
      client.track(keywords)
    end

    desc "timeline", "Stream your timeline (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def timeline
      client.on_inited do
        cli = T::CLI.new
        cli.options = cli.options.merge(options)
        cli.options = cli.options.merge(:reverse => true)
        cli.options = cli.options.merge(:format => STATUS_HEADINGS_FORMATTING)
        cli.timeline
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        elsif options['long']
          print_table build_long_status(status).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
        else
          print_status(status)
        end
      end
      until_term
      client.userstream
    end

    desc "users SCREEN_NAME [SCREEN_NAME...]", "Stream Tweets either from or in reply to specified users (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def users(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      client.on_inited do
        if options['csv']
          say STATUS_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          say STATUS_HEADINGS.size.times.map do |index|
            STATUS_HEADINGS_FORMATTING[index] % STATUS_HEADINGS[index]
          end
        end
      end
      client.on_timeline_status do |status|
        if options['csv']
          print_csv_status(status)
        elsif options['long']
          print_table(build_long_status(status))
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
