require 't/core_ext/string'
require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class CLI
    class Set < Thor
      DEFAULT_HOST = 'api.twitter.com'
      DEFAULT_PROTOCOL = 'https'

      check_unknown_options!

      def initialize(*)
        super
        @rcfile = RCFile.instance
      end

      desc "bio DESCRIPTION", "Edits your Bio information on your Twitter profile."
      def bio(description)
        client.update_profile(:description => description)
        say "@#{@rcfile.default_profile[0]}'s bio has been updated."
      end

      desc "default USERNAME [CONSUMER_KEY]", "Set your default account."
      def default(username, consumer_key=nil)
        username = username.strip_at
        @rcfile.path = parent_options['profile'] if parent_options['profile']
        consumer_key = rcfile[username].keys.last if consumer_key.nil?
        @rcfile.default_profile = {'username' => username, 'consumer_key' => consumer_key}
        say "Default account has been updated."
      end

      desc "language LANGUAGE_NAME", "Selects the language you'd like to receive notifications in."
      def language(language_name)
        client.settings(:lang => language_name)
        say "@#{@rcfile.default_profile[0]}'s language has been updated."
      end

      desc "location PLACE_NAME", "Updates the location field in your profile."
      def location(place_name)
        client.update_profile(:location => place_name)
        say "@#{@rcfile.default_profile[0]}'s location has been updated."
      end

      desc "name NAME", "Sets the name field on your Twitter profile."
      def name(name)
        client.update_profile(:name => name)
        say "@#{@rcfile.default_profile[0]}'s name has been updated."
      end

      desc "url URL", "Sets the URL field on your profile."
      def url(url)
        client.update_profile(:url => url)
        say "@#{@rcfile.default_profile[0]}'s URL has been updated."
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
