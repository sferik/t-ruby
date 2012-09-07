require 'thor'
require 't/printable'
require 't/rcfile'

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
      @rcfile = T::RCFile.instance
      super
    end

    desc "all", "Stream a random sample of all Tweets (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def all
      require 'tweetstream'
      client.on_inited do
        if options['csv']
          require 'csv'
          require 'fastercsv' unless Array.new.respond_to?(:to_csv)
          say STATUS_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          headings = STATUS_HEADINGS.size.times.map do |index|
            STATUS_HEADINGS_FORMATTING[index] % STATUS_HEADINGS[index]
          end
          print_table([headings])
        end
      end
      client.on_timeline_status do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
      client.sample
    end

    desc "matrix", "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."
    def matrix
      require 'tweetstream'
      client.on_timeline_status do |tweet|
        say(tweet.full_text.gsub("\n", ''), [:bold, :green, :on_black])
      end
      client.sample
    end

    desc "search KEYWORD [KEYWORD...]", "Stream Tweets that contain specified keywords, joined with logical ORs (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def search(keyword, *keywords)
      keywords.unshift(keyword)
      require 'tweetstream'
      require 't/search'
      client.on_inited do
        search = T::Search.new
        search.options = search.options.merge(options)
        search.options = search.options.merge(:reverse => true)
        search.options = search.options.merge(:format => STATUS_HEADINGS_FORMATTING)
        search.all(keywords.join(' OR '))
      end
      client.on_timeline_status do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
      client.track(keywords)
    end

    desc "timeline", "Stream your timeline (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def timeline
      require 'tweetstream'
      require 't/cli'
      client.on_inited do
        cli = T::CLI.new
        cli.options = cli.options.merge(options)
        cli.options = cli.options.merge(:reverse => true)
        cli.options = cli.options.merge(:format => STATUS_HEADINGS_FORMATTING)
        cli.timeline
      end
      client.on_timeline_status do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
      client.userstream
    end

    desc "users USER_ID [USER_ID...]", "Stream Tweets either from or in reply to specified users (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def users(user_id, *user_ids)
      user_ids.unshift(user_id)
      user_ids.map!(&:to_i)
      require 'tweetstream'
      client.on_inited do
        if options['csv']
          require 'csv'
          require 'fastercsv' unless Array.new.respond_to?(:to_csv)
          say STATUS_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          headings = STATUS_HEADINGS.size.times.map do |index|
            STATUS_HEADINGS_FORMATTING[index] % STATUS_HEADINGS[index]
          end
          print_table([headings])
        end
      end
      client.on_timeline_status do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            STATUS_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
      client.follow(user_ids)
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

  end
end
