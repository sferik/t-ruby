require 'action_view'
require 'csv'
# 'fastercsv' required on Ruby versions < 1.9
require 'fastercsv' unless Array.new.respond_to?(:to_csv)
require 'highline'
require 'htmlentities'
require 'thor/shell/color'
require 'time'

module T
  module Printable
    MAX_SCREEN_NAME_SIZE = 20
    include ActionView::Helpers::NumberHelper

    def self.included(base)

    private

      def build_long_list(list)
        created_at = if Time.parse(list.created_at.to_s) > 6.months.ago
          list.created_at.strftime("%b %e %H:%M")
        else
          list.created_at.strftime("%b %e  %Y")
        end
        [list.id, created_at, "@#{list.user.screen_name}", list.slug, number_with_delimiter(list.member_count), number_with_delimiter(list.subscriber_count), list.mode, list.description]
      end

      def build_long_status(status)
        created_at = if Time.parse(status.created_at.to_s) > 6.months.ago
          Time.parse(status.created_at.to_s).strftime("%b %e %H:%M")
        else
          Time.parse(status.created_at.to_s).strftime("%b %e  %Y")
        end
        [status.id, created_at, "@#{status.user.screen_name}", HTMLEntities.new.decode(status.text).gsub(/\n+/, ' ')]
      end

      def build_long_user(user)
        created_at = if user.created_at > 6.months.ago
          Time.parse(user.created_at.to_s).strftime("%b %e %H:%M")
        else
          user.created_at.strftime("%b %e  %Y")
        end
        [user.id, created_at, number_with_delimiter(user.statuses_count), number_with_delimiter(user.favourites_count), number_with_delimiter(user.listed_count), number_with_delimiter(user.friends_count), number_with_delimiter(user.followers_count), "@#{user.screen_name}", user.name]
      end

      def print_csv_list(list)
        created_at = Time.parse(list.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [list.id, created_at, list.user.screen_name, list.slug, list.member_count, list.subscriber_count, list.mode, list.description].to_csv
      end

      def print_csv_status(status)
        created_at = Time.parse(status.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [status.id, created_at, status.user.screen_name, HTMLEntities.new.decode(status.text)].to_csv
      end

      def print_csv_user(user)
        created_at = Time.parse(user.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [user.id, created_at, user.statuses_count, user.favourites_count, user.listed_count, user.friends_count, user.followers_count, user.screen_name, user.name].to_csv
      end

      def print_in_columns(array)
        cols = HighLine::SystemExtensions.terminal_size[0]
        width = (array.map{|el| el.to_s.size}.max || 0) + 2
        array.each_with_index do |value, index|
          puts if (((index) % (cols / width))).zero? && !index.zero?
          printf("%-#{width}s", value)
        end
        puts
      end

      def list_headings
        ["ID", "Created at", "Screen name", "Slug", "Members", "Subscribers", "Mode", "Description"]
      end

      def status_headings
        ["ID", "Posted at", "Screen name", "Text"]
      end

      def print_lists(lists)
        lists = lists.sort_by{|list| list.slug.downcase} unless options['unsorted']
        if options['posted']
          lists = lists.sort_by{|user| user.created_at}
        elsif options['members']
          lists = lists.sort_by{|user| user.member_count}
        elsif options['mode']
          lists = lists.sort_by{|user| user.mode}
        elsif options['subscribers']
          lists = lists.sort_by{|user| user.subscriber_count}
        end
        lists.reverse! if options['reverse']
        if options['csv']
          say list_headings.to_csv unless lists.empty?
          lists.each do |list|
            print_csv_list(list)
          end
        elsif options['long']
          array = lists.map do |list|
            build_long_list(list)
          end
          if STDOUT.tty?
            array.unshift(list_headings) unless lists.empty?
            print_table(array, :truncate => true)
          else
            print_table(array)
          end
        else
          if STDOUT.tty?
            print_in_columns(lists.map(&:full_name))
          else
            lists.each do |list|
              say list.full_name
            end
          end
        end
      end

      def print_status(status)
        if STDOUT.tty? && !options['no-color']
          say("   @#{status.user.screen_name}", [:bold, :yellow])
          print_wrapped(HTMLEntities.new.decode(status.text), :indent => 3)
        else
          say("   @#{status.user.screen_name}")
          print_wrapped(HTMLEntities.new.decode(status.text), :indent => 3)
        end
        say
      end

      def print_statuses(statuses)
        statuses.reverse! if options['reverse'] || options['stream']
        if options['csv']
          say status_headings.to_csv unless statuses.empty?
          statuses.each do |status|
            print_csv_status(status)
          end
        elsif options['long']
          array = statuses.map do |status|
            build_long_status(status)
          end
          if STDOUT.tty?
            array.unshift(status_headings) unless statuses.empty?
            print_table(array, :truncate => true)
          else
            print_table(array)
          end
        else
          statuses.each do |status|
            print_status(status)
          end
        end
      end

      def user_headings
        ["ID", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "Screen name", "Name"]
      end

      def print_users(users)
        users = users.sort_by{|user| user.screen_name.downcase} unless options['unsorted']
        if options['posted']
          users = users.sort_by{|user| user.created_at}
        elsif options['favorites']
          users = users.sort_by{|user| user.favourites_count}
        elsif options['followers']
          users = users.sort_by{|user| user.followers_count}
        elsif options['friends']
          users = users.sort_by{|user| user.friends_count}
        elsif options['listed']
          users = users.sort_by{|user| user.listed_count}
        elsif options['tweets']
          users = users.sort_by{|user| user.statuses_count}
        end
        users.reverse! if options['reverse']
        if options['csv']
          say user_headings.to_csv unless users.empty?
          users.each do |user|
            print_csv_user(user)
          end
        elsif options['long']
          array = users.map do |user|
            build_long_user(user)
          end
          if STDOUT.tty?
            array.unshift(user_headings) unless users.empty?
            print_table(array, :truncate => true)
          else
            print_table(array)
          end
        else
          if STDOUT.tty?
            print_in_columns(users.map{|user| "@#{user.screen_name}"})
          else
            users.each do |user|
              say "@#{user.screen_name}"
            end
          end
        end
      end

    end

  end
end
