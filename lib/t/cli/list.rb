require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class List < Thor
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
