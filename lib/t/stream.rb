require 't/printable'
require 't/rcfile'
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
    def all
      client.on_timeline_status do |status|
        print_status(status)
      end
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
      client.sample
    end

    desc "matrix", "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."
    def matrix
      client.on_timeline_status do |status|
        print("#{Thor::Shell::Color::BOLD}#{Thor::Shell::Color::GREEN}#{Thor::Shell::Color::ON_BLACK}#{status.text.gsub("\n", '')}#{Thor::Shell::Color::CLEAR}")
      end
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
      client.sample
    end

    desc "search KEYWORD [KEYWORD...]", "Stream Tweets that contain specified keywords, joined with logical ORs (Control-C to stop)"
    def search(keyword, *keywords)
      keywords.unshift(keyword)
      client.on_timeline_status do |status|
        print_status(status)
      end
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
      client.track(keywords)
    end

    desc "timeline", "Stream your timeline (Control-C to stop)"
    def timeline
      client.on_timeline_status do |status|
        print_status(status)
      end
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
      client.userstream
    end

    desc "users SCREEN_NAME [SCREEN_NAME...]", "Stream Tweets either from or in reply to specified users (Control-C to stop)"
    def users(screen_name, *screen_names)
      screen_names.unshift(screen_name)
      client.on_timeline_status do |status|
        print_status(status)
      end
      Signal.trap("TERM") do
        client.stop
        shutdown
      end
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

  end
end
