require 'thor'
require 't/printable'
require 't/rcfile'

module T
  class Stream < Thor
    include T::Printable
    include T::Utils

    TWEET_HEADINGS_FORMATTING = [
      "%-18s",  # Add padding to maximum length of a Tweet ID
      "%-12s",  # Add padding to length of a timestamp formatted with ls_formatted_time
      "%-20s",  # Add padding to maximum length of a Twitter screen name
      "%s",     # Last element does not need special formatting
    ]

    check_unknown_options!

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
    end

    desc "all", "Stream a random sample of all Tweets (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def all
      client.before_request do
        if options['csv']
          require 'csv'
          say TWEET_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          headings = TWEET_HEADINGS.size.times.map do |index|
            TWEET_HEADINGS_FORMATTING[index] % TWEET_HEADINGS[index]
          end
          print_table([headings])
        end
      end
      client.sample do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            TWEET_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
    end

    desc "matrix", "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."
    def matrix
      client.sample do |tweet|
        say(tweet.full_text.gsub("\n", ''), [:bold, :green, :on_black])
      end
    end

    desc "search KEYWORD [KEYWORD...]", "Stream Tweets that contain specified keywords, joined with logical ORs (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def search(keyword, *keywords)
      keywords.unshift(keyword)
      require 't/search'
      client.before_request do
        search = T::Search.new
        search.options = search.options.merge(options)
        search.options = search.options.merge(:reverse => true)
        search.options = search.options.merge(:format => TWEET_HEADINGS_FORMATTING)
        search.all(keywords.join(' OR '))
      end
      client.filter(:track => keywords) do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            TWEET_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
    end

    desc "timeline", "Stream your timeline (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def timeline
      require 't/cli'
      client.before_request do
        cli = T::CLI.new
        cli.options = cli.options.merge(options)
        cli.options = cli.options.merge(:reverse => true)
        cli.options = cli.options.merge(:format => TWEET_HEADINGS_FORMATTING)
        cli.timeline
      end
      client.user do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            TWEET_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
    end

    desc "users USER_ID [USER_ID...]", "Stream Tweets either from or in reply to specified users (Control-C to stop)"
    method_option "csv", :aliases => "-c", :type => :boolean, :default => false, :desc => "Output in CSV format."
    method_option "long", :aliases => "-l", :type => :boolean, :default => false, :desc => "Output in long format."
    def users(user_id, *user_ids)
      user_ids.unshift(user_id)
      user_ids.map!(&:to_i)
      client.before_request do
        if options['csv']
          require 'csv'
          say TWEET_HEADINGS.to_csv
        elsif options['long'] && STDOUT.tty?
          headings = TWEET_HEADINGS.size.times.map do |index|
            TWEET_HEADINGS_FORMATTING[index] % TWEET_HEADINGS[index]
          end
          print_table([headings])
        end
      end
      client.follow(user_ids) do |tweet|
        if options['csv']
          print_csv_tweet(tweet)
        elsif options['long']
          array = build_long_tweet(tweet).each_with_index.map do |element, index|
            TWEET_HEADINGS_FORMATTING[index] % element
          end
          print_table([array], :truncate => STDOUT.tty?)
        else
          print_message(tweet.user.screen_name, tweet.text)
        end
      end
    end

  private

    def client
      return @client if @client
      @rcfile.path = options['profile'] if options['profile']
      @client = Twitter::Streaming::Client.new do |config|
        config.consumer_key        = @rcfile.active_consumer_key
        config.consumer_secret     = @rcfile.active_consumer_secret
        config.access_token        = @rcfile.active_token
        config.access_token_secret = @rcfile.active_secret
      end
    end

  end
end
