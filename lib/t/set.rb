require 'thor'
require 't/rcfile'
require 't/requestable'

module T
  class Set < Thor
    include T::Requestable

    attr_reader :rcfile

    check_unknown_options!

    class_option "host", :aliases => "-H", :type => :string, :default => T::Requestable::DEFAULT_HOST, :desc => "Twitter API server"
    class_option "no-color", :aliases => "-N", :type => :boolean, :desc => "Disable colorization in output"
    class_option "no-ssl", :aliases => "-U", :type => :boolean, :default => false, :desc => "Disable SSL"
    class_option "profile", :aliases => "-P", :type => :string, :default => File.join(File.expand_path("~"), T::RCFile::FILE_NAME), :desc => "Path to RC file", :banner => "FILE"

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
    end

    desc "active SCREEN_NAME [CONSUMER_KEY]", "Set your active account."
    def active(screen_name, consumer_key=nil)
      rcfile.path = options['profile']
      require 't/core_ext/string'
      screen_name = screen_name.strip_ats
      consumer_key = rcfile[screen_name].keys.last if consumer_key.nil?
      rcfile.active_profile = {'username' => rcfile[screen_name][consumer_key]["username"], 'consumer_key' => consumer_key}
      say "Active account has been updated to #{rcfile.active_profile[0]}."
    end
    map %w(default) => :active

    desc "bio DESCRIPTION", "Edits your Bio information on your Twitter profile."
    def bio(description)
      client.update_profile(:description => description)
      say "@#{rcfile.active_profile[0]}'s bio has been updated."
    end

    desc "language LANGUAGE_NAME", "Selects the language you'd like to receive notifications in."
    def language(language_name)
      rcfile.path = options['profile']
      client.settings(:lang => language_name)
      say "@#{rcfile.active_profile[0]}'s language has been updated."
    end

    desc "location PLACE_NAME", "Updates the location field in your profile."
    def location(place_name)
      rcfile.path = options['profile']
      client.update_profile(:location => place_name)
      say "@#{rcfile.active_profile[0]}'s location has been updated."
    end

    desc "name NAME", "Sets the name field on your Twitter profile."
    def name(name)
      rcfile.path = options['profile']
      client.update_profile(:name => name)
      say "@#{rcfile.active_profile[0]}'s name has been updated."
    end

    desc "profile_background_image FILE", "Sets the background image on your Twitter profile."
    method_option "tile", :aliases => "-t", :type => :boolean, :default => false, :desc => "Whether or not to tile the background image."
    def profile_background_image(file)
      rcfile.path = options['profile']
      client.update_profile_background_image(File.new(File.expand_path(file)), :tile => options['tile'], :skip_status => true)
      say "@#{rcfile.active_profile[0]}'s background image has been updated."
    end
    map %w(background background_image) => :profile_background_image

    desc "profile_image FILE", "Sets the image on your Twitter profile."
    def profile_image(file)
      rcfile.path = options['profile']
      client.update_profile_image(File.new(File.expand_path(file)))
      say "@#{rcfile.active_profile[0]}'s image has been updated."
    end
    map %w(avatar image) => :profile_image

    desc "url URL", "Sets the URL field on your profile."
    def url(url)
      rcfile.path = options['profile']
      client.update_profile(:url => url)
      say "@#{rcfile.active_profile[0]}'s URL has been updated."
    end

  end
end
