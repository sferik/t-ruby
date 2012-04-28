require 'twitter'

module T
  module Requestable
    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'

    def self.included(base)

    private

      def base_url
        "#{protocol}://#{host}"
      end

      def client
        return @client if @client
        @rcfile.path = options['profile'] if options['profile']
        @client = Twitter::Client.new(
          :endpoint => base_url,
          :consumer_key => @rcfile.active_consumer_key,
          :consumer_secret => @rcfile.active_consumer_secret,
          :oauth_token => @rcfile.active_token,
          :oauth_token_secret  => @rcfile.active_secret
        )
      end

      def host
        options['host'] || DEFAULT_HOST
      end

      def protocol
        options['no_ssl'] ? 'http' : DEFAULT_PROTOCOL
      end

    end

  end
end
