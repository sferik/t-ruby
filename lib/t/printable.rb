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
    DIRECT_MESSAGE_HEADINGS = ["ID", "Posted at", "Screen name", "Text"]
    LIST_HEADINGS =["ID", "Created at", "Screen name", "Slug", "Members", "Subscribers", "Mode", "Description"]
    STATUS_HEADINGS = ["ID", "Posted at", "Screen name", "Text"]
    TREND_HEADINGS = ["WOEID", "Parent ID", "Type", "Name", "Country"]
    USER_HEADINGS = ["ID", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "Screen name", "Name"]

    include ActionView::Helpers::NumberHelper

    def self.included(base)

    private

      def build_long_list(list)
        created_at = formatted_date(list)
        [list.id, created_at, "@#{list.user.screen_name}", list.slug, number_with_delimiter(list.member_count), number_with_delimiter(list.subscriber_count), list.mode, list.description]
      end

      def build_long_status(status)
        created_at = formatted_date(status)
        [status.id, created_at, "@#{status.from_user}", HTMLEntities.new.decode(status.text).gsub(/\n+/, ' ')]
      end

      def build_long_user(user)
        created_at = formatted_date(user)
        [user.id, created_at, number_with_delimiter(user.statuses_count), number_with_delimiter(user.favourites_count), number_with_delimiter(user.listed_count), number_with_delimiter(user.friends_count), number_with_delimiter(user.followers_count), "@#{user.screen_name}", user.name]
      end

      def formatted_date(object)
        created_at = if object.created_at > 6.months.ago
          Time.parse(object.created_at.to_s).strftime("%b %e %H:%M")
        else
          Time.parse(object.created_at.to_s).strftime("%b %e  %Y")
        end
      end

      def print_columns(array)
        cols = HighLine::SystemExtensions.terminal_size[0]
        width = (array.map{|el| el.to_s.size}.max || 0) + 2
        array.each_with_index do |value, index|
          puts if (((index) % (cols / width))).zero? && !index.zero?
          printf("%-#{width}s", value)
        end
        puts
      end

      def print_csv_list(list)
        created_at = Time.parse(list.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [list.id, created_at, list.user.screen_name, list.slug, list.member_count, list.subscriber_count, list.mode, list.description].to_csv
      end

      def print_csv_status(status)
        created_at = Time.parse(status.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [status.id, created_at, status.from_user, HTMLEntities.new.decode(status.text)].to_csv
      end

      def print_csv_user(user)
        created_at = Time.parse(user.created_at.to_s).utc.strftime("%Y-%m-%d %H:%M:%S %z")
        say [user.id, created_at, user.statuses_count, user.favourites_count, user.listed_count, user.friends_count, user.followers_count, user.screen_name, user.name].to_csv
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
          say LIST_HEADINGS.to_csv unless lists.empty?
          lists.each do |list|
            print_csv_list(list)
          end
        elsif options['long']
          array = lists.map do |list|
            build_long_list(list)
          end
          print_table_with_headings(array, LIST_HEADINGS)
        else
          print_attribute(lists, :full_name)
        end
      end

      def print_attribute(array, attribute)
        if STDOUT.tty?
          print_columns(array.map(&attribute.to_sym))
        else
          array.each do |element|
            say element.send(attribute.to_sym)
          end
        end
      end

      def print_table_with_headings(array, headings)
        if STDOUT.tty?
          array.unshift(headings) unless array.flatten.empty?
          print_table(array, :truncate => true)
        else
          print_table(array)
        end
      end

      def print_status(status)
        if STDOUT.tty? && !options['no-color']
          say("   @#{status.from_user}", [:bold, :yellow])
        else
          say("   @#{status.from_user}")
        end
        print_wrapped(HTMLEntities.new.decode(status.text), :indent => 3)
        say
      end

      def print_statuses(statuses)
        statuses.reverse! if options['reverse'] || options['stream']
        if options['csv']
          say STATUS_HEADINGS.to_csv unless statuses.empty?
          statuses.each do |status|
            print_csv_status(status)
          end
        elsif options['long']
          array = statuses.map do |status|
            build_long_status(status)
          end
          print_table_with_headings(array, STATUS_HEADINGS)
        else
          statuses.each do |status|
            print_status(status)
          end
        end
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
          say USER_HEADINGS.to_csv unless users.empty?
          users.each do |user|
            print_csv_user(user)
          end
        elsif options['long']
          array = users.map do |user|
            build_long_user(user)
          end
          print_table_with_headings(array, USER_HEADINGS)
        else
          print_attribute(users, :screen_name)
        end
      end

    end

  end
end
