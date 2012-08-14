require 'thor'
require 'twitter'

module T
  autoload :RCFile, 't/rcfile'
  autoload :Requestable, 't/requestable'
  autoload :Utils, 't/utils'
  class Delete < Thor
    include T::Requestable
    include T::Utils

    check_unknown_options!

    def initialize(*)
      @rcfile = T::RCFile.instance
      super
    end

    desc "block USER [USER...]", "Unblock users."
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify input as Twitter user IDs instead of screen names."
    method_option "force", :aliases => "-f", :type => :boolean, :default => false
    def block(user, *users)
      users = fetch_users(users.unshift(user), options) do |users|
        client.unblock(users)
      end
      number = users.length
      say "@#{@rcfile.active_profile[0]} unblocked #{number} #{number == 1 ? 'user' : 'users'}."
      say
      say "Run `#{File.basename($0)} block #{users.map{|user| "@#{user.screen_name}"}.join(' ')}` to block."
    end

    desc "dm [DIRECT_MESSAGE_ID] [DIRECT_MESSAGE_ID...]", "Delete the last Direct Message sent."
    method_option "force", :aliases => "-f", :type => :boolean, :default => false
    def dm(direct_message_id, *direct_message_ids)
      direct_message_ids.unshift(direct_message_id)
      require 't/core_ext/string'
      direct_message_ids.map!(&:to_i)
      if options['force']
        direct_messages = client.direct_message_destroy(direct_message_ids)
        direct_messages.each do |direct_message|
          say "@#{@rcfile.active_profile[0]} deleted the direct message sent to @#{direct_message.recipient.screen_name}: \"#{direct_message.text}\""
        end
      else
        direct_message_ids.each do |direct_message_id|
          direct_message = client.direct_message(direct_message_id)
          return unless yes? "Are you sure you want to permanently delete the direct message to @#{direct_message.recipient.screen_name}: \"#{direct_message.text}\"? [y/N]"
          client.direct_message_destroy(direct_message_id)
          say "@#{@rcfile.active_profile[0]} deleted the direct message sent to @#{direct_message.recipient.screen_name}: \"#{direct_message.text}\""
        end
      end

    end
    map %w(d m) => :dm

    desc "favorite STATUS_ID [STATUS_ID...]", "Delete favorites."
    method_option "force", :aliases => "-f", :type => :boolean, :default => false
    def favorite(status_id, *status_ids)
      status_ids.unshift(status_id)
      require 't/core_ext/string'
      status_ids.map!(&:to_i)
      if options['force']
        statuses = client.unfavorite(status_ids)
        statuses.each do |status|
          say "@#{@rcfile.active_profile[0]} unfavorited @#{status.from_user}'s status: \"#{status.full_text}\""
        end
      else
        status_ids.each do |status_id|
          status = client.status(status_id, :include_my_retweet => false, :trim_user => true)
          return unless yes? "Are you sure you want to remove @#{status.from_user}'s status: \"#{status.full_text}\" from your favorites? [y/N]"
          client.unfavorite(status_id)
          say "@#{@rcfile.active_profile[0]} unfavorited @#{status.from_user}'s status: \"#{status.full_text}\""
        end
      end
    end
    map %w(fave favourite) => :favorite

    desc "list LIST", "Delete a list."
    method_option "force", :aliases => "-f", :type => :boolean, :default => false
    method_option "id", :aliases => "-i", :type => "boolean", :default => false, :desc => "Specify list via ID instead of slug."
    def list(list)
      if options['id']
        require 't/core_ext/string'
        list = list.to_i
      end
      list = client.list(list)
      unless options['force']
        return unless yes? "Are you sure you want to permanently delete the list \"#{list.name}\"? [y/N]"
      end
      client.list_destroy(list)
      say "@#{@rcfile.active_profile[0]} deleted the list \"#{list.name}\"."
    end

    desc "status STATUS_ID [STATUS_ID...]", "Delete Tweets."
    method_option "force", :aliases => "-f", :type => :boolean, :default => false
    def status(status_id, *status_ids)
      status_ids.unshift(status_id)
      require 't/core_ext/string'
      status_ids.map!(&:to_i)
      if options['force']
        statuses = client.status_destroy(status_ids, :trim_user => true)
        statuses.each do |status|
          say "@#{@rcfile.active_profile[0]} deleted the status: \"#{status.full_text}\""
        end
      else
        status_ids.each do |status_id|
          status = client.status(status_id, :include_my_retweet => false, :trim_user => true)
          return unless yes? "Are you sure you want to permanently delete @#{status.from_user}'s status: \"#{status.full_text}\"? [y/N]"
          client.status_destroy(status_id, :trim_user => true)
          say "@#{@rcfile.active_profile[0]} deleted the status: \"#{status.full_text}\""
        end
      end
    end
    map %w(post tweet update) => :status

  end
end
