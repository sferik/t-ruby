require 'action_view'
require 'highline'

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

      def print_status_list(statuses)
        statuses.reverse! if options['reverse']
        if options['long']
          array = statuses.map do |status|
            created_at = status.created_at > 6.months.ago ? status.created_at.strftime("%b %e %H:%M") : status.created_at.strftime("%b %e  %Y")
            [number_with_delimiter(status.id), created_at, "@#{status.user.screen_name}", status.text.gsub(/\n+/, ' ')]
          end
          if STDOUT.tty?
            headings = ["ID", "Posted at", "Screen name", "Text"]
            array.unshift(headings) unless statuses.empty?
          end
          print_table(array)
        else
          statuses.each do |status|
            say "#{status.user.screen_name.rjust(MAX_SCREEN_NAME_SIZE)}: #{status.text.gsub(/\n+/, ' ')} (#{time_ago_in_words(status.created_at)} ago)"
          end
        end
      end

      def print_user_list(users)
        users = users.sort_by{|user| user.screen_name.downcase} unless options['unsorted']
        if options['created']
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
        if options['long']
          array = users.map do |user|
            created_at = user.created_at > 6.months.ago ? user.created_at.strftime("%b %e %H:%M") : user.created_at.strftime("%b %e  %Y")
            [number_with_delimiter(user.id), created_at, number_with_delimiter(user.statuses_count), number_with_delimiter(user.favourites_count), number_with_delimiter(user.listed_count), number_with_delimiter(user.friends_count), number_with_delimiter(user.followers_count), "@#{user.screen_name}", user.name]
          end
          if STDOUT.tty?
            headings = ["ID", "Since", "Tweets", "Favorites", "Listed", "Following", "Followers", "Screen name", "Name"]
            array.unshift(headings) unless users.empty?
          end
          print_table(array)
        else
          if STDOUT.tty?
            print_in_columns(users.map(&:screen_name))
          else
            users.each do |user|
              say user.screen_name
            end
          end
        end
      end

    end

  end
end
