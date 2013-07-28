require 'twitter'

module T
  module Requestable

  private

    def client
      return @client if @client
      @rcfile.path = options['profile'] if options['profile']
      @client = Twitter::REST::Client.new(
        :consumer_key => @rcfile.active_consumer_key,
        :consumer_secret => @rcfile.active_consumer_secret,
        :oauth_token => @rcfile.active_token,
        :oauth_token_secret => @rcfile.active_secret,
      )
    end

  end
end
