require 'thor'

module T
  autoload :RCFile, 't/rcfile'
  autoload :Requestable, 't/requestable'
  class Set < Thor
    include T::Requestable

    check_unknown_options!

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
    end

    desc "active SCREEN_NAME [CONSUMER_KEY]", "Set your active account."
    def active(screen_name, consumer_key=nil)
      require 't/core_ext/string'
      screen_name = screen_name.strip_ats
      @rcfile.path = options['profile'] if options['profile']
      consumer_key = @rcfile[screen_name].keys.last if consumer_key.nil?
      @rcfile.active_profile = {'username' => screen_name, 'consumer_key' => consumer_key}
      say "Active account has been updated."
    end
    map %w(default) => :active

    desc "bio DESCRIPTION", "Edits your Bio information on your Twitter profile."
    def bio(description)
      client.update_profile(:description => description)
      say "@#{@rcfile.active_profile[0]}'s bio has been updated."
    end

    desc "language LANGUAGE_NAME", "Selects the language you'd like to receive notifications in."
    def language(language_name)
      client.settings(:lang => language_name)
      say "@#{@rcfile.active_profile[0]}'s language has been updated."
    end

    desc "location PLACE_NAME", "Updates the location field in your profile."
    def location(place_name)
      client.update_profile(:location => place_name)
      say "@#{@rcfile.active_profile[0]}'s location has been updated."
    end

    desc "name NAME", "Sets the name field on your Twitter profile."
    def name(name)
      client.update_profile(:name => name)
      say "@#{@rcfile.active_profile[0]}'s name has been updated."
    end

    desc "url URL", "Sets the URL field on your profile."
    def url(url)
      client.update_profile(:url => url)
      say "@#{@rcfile.active_profile[0]}'s URL has been updated."
    end

  end
end
