require 'action_view'
require 'csv'
# 'fastercsv' required on Ruby versions < 1.9
require 'fastercsv' unless Array.new.respond_to?(:to_csv)
require 'highline'
require 'thor/shell/color'

module T
  module Printable
    MAX_SCREEN_NAME_SIZE = 20
    include ActionView::Helpers::NumberHelper

    def self.included(base)

    private

      def print_in_columns(array)
        cols = HighLine::SystemExtensions.terminal_size[0]
        width = (array.map{|el| el.to_s.size}.max || 0) + 2
        array.each_with_index do |value, index|
          puts if (((index) % (cols / width))).zero? && !index.zero?
          printf("%-#{width}s", value)
        end
        puts
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
          say ["ID", "Created at", "Screen name", "Slug", "Members", "Subscribers", "Mode", "Description"].to_csv unless lists.empty?
          lists.each do |list|
            say [list.id, list.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), list.user.screen_name, list.slug, list.member_count, list.subscriber_count, list.mode, list.description].to_csv
          end
        elsif options['long']
          array = lists.map do |list|
            created_at = list.created_at > 6.months.ago ? list.created_at.strftime("%b %e %H:%M") : list.created_at.strftime("%b %e  %Y")
            [list.id, created_at, list.full_name, number_with_delimiter(list.member_count), number_with_delimiter(list.subscriber_count), list.mode, list.description]
          end
          if STDOUT.tty?
            headings = ["ID", "Created at", "Slug", "Members", "Subscribers", "Mode", "Description"]
            array.unshift(headings) unless lists.empty?
          end
          print_table(array)
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

      def print_statuses(statuses)
        statuses.reverse! if options['reverse']
        if options['csv']
          say ["ID", "Posted at", "Screen name", "Text"].to_csv unless statuses.empty?
          statuses.each do |status|
            say [status.id, status.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), status.user.screen_name, status.text].to_csv
          end
        elsif options['long']
          array = statuses.map do |status|
            created_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
            [status.id, created_at, "@#{status.user.screen_name}", status.text.gsub(/\n+/, ' ')]
          end
          if STDOUT.tty?
            headings = ["ID", "Posted at", "Screen name", "Text"]
            array.unshift(headings) unless statuses.empty?
          end
          print_table(array)
        else
          ENV['THOR_COLUMNS'] = "80"
          if STDOUT.tty? && !options['no-color']
            say unless statuses.empty?
            statuses.each do |status|
              say("   #{Thor::Shell::Color::BOLD}@#{status.user.screen_name}", :yellow)
              print_wrapped(status.text, :indent => 3)
              say("   #{Thor::Shell::Color::BOLD}#{time_ago_in_words(status.created_at)} ago", :black)
              say
            end
          else
            say unless statuses.empty?
            statuses.each do |status|
              say("   @#{status.user.screen_name}")
              print_wrapped(status.text, :indent => 3)
              say("   #{time_ago_in_words(status.created_at)} ago")
              say
            end
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
          say ["ID", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "Screen name", "Name"].to_csv unless users.empty?
          users.each do |user|
            say [user.id, user.created_at.utc.strftime("%Y-%m-%d %H:%M:%S %z"), user.statuses_count, user.favourites_count, user.listed_count, user.friends_count, user.followers_count, user.screen_name, user.name].to_csv
          end
        elsif options['long']
          array = users.map do |user|
            created_at = user.created_at > 6.months.ago ? user.created_at.strftime("%b %e %H:%M") : user.created_at.strftime("%b %e  %Y")
            [user.id, created_at, number_with_delimiter(user.statuses_count), number_with_delimiter(user.favourites_count), number_with_delimiter(user.listed_count), number_with_delimiter(user.friends_count), number_with_delimiter(user.followers_count), "@#{user.screen_name}", user.name]
          end
          if STDOUT.tty?
            headings = ["ID", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "Screen name", "Name"]
            array.unshift(headings) unless users.empty?
          end
          print_table(array)
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
