require 't/rcfile'
require 'thor'
require 'twitter'

module T
  class Delete < Thor
    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'

    class_option "profile", :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

    desc "block USERNAME", "Unblock a user."
    def block(username)
      username = username.strip_at
      client.unblock(username)
      rcfile = RCFile.instance
      rcfile.path = options['profile'] if options['profile']
      say "@#{rcfile.default_profile[0]} unblocked @#{username}"
      say
      say "Run `#{$0} block #{username}` to block."
    end

    desc "favorite USERNAME", "Unmarks that user's last Tweet as one of your favorites."
    def favorite(username)
      username = username.strip_at
      status = client.user_timeline(username, :count => 1).first
      if status
        client.unfavorite(status.id)
        rcfile = RCFile.instance
        rcfile.path = options['profile'] if options['profile']
        say "@#{rcfile.default_profile[0]} unfavorited @#{username}'s latest status: #{status.text}"
        say
        say "Run `#{$0} favorite #{username}` to favorite."
      else
        raise Thor::Error, "No status found"
      end
    end

    no_tasks do

      def base_url
        "#{protocol}://#{host}"
      end

      def client
        rcfile = RCFile.instance
        rcfile.path = options['profile'] if options['profile']
        Twitter::Client.new(
          :endpoint => base_url,
          :consumer_key => rcfile.default_consumer_key,
          :consumer_secret => rcfile.default_consumer_secret,
          :oauth_token => rcfile.default_token,
          :oauth_token_secret  => rcfile.default_secret
        )
      end

      def host
        parent_options['host'] || DEFAULT_HOST
      end

      def protocol
        parent_options['no-ssl'] ? 'http' : DEFAULT_PROTOCOL
      end

    end
  end
end
