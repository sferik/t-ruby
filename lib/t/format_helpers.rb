require 'date'

module T
  module FormatHelpers
    private

    # https://github.com/rails/rails/blob/bd8a970/actionpack/lib/action_view/helpers/date_helper.rb
    def distance_of_time_in_words_to_now(from_time)
      to_time = Time.now
      seconds = (to_time - from_time).abs
      minutes = seconds / 60
      case minutes
      when 0...1
        case seconds
        when 0...1
          'less than a second'
        when 1...2
          '1 second'
        when 2..29
          '%d seconds' % seconds
        when 30..39
          'half a minute'
        else
          'less than a minute'
        end
      when 1...2
        '1 minute'
      when 2..44
        '%d minutes' % minutes
      when 45..89
        'about an hour'
      # 90 minutes up to 24 hours
      when 90..1439
        'about %d hours' % (minutes.to_f / 60.0).round
      # 24 hours up to 42 hours
      when 1440..2519
        '1 day'
      # 42 hours up to 30 days
      when 2520..43199
        '%d days' % (minutes.to_f / 1440.0).round
      # 30 days up to 60 days
      when 43200..86399
        'about a month'
      # 60 days up to 365 days
      when 86400..525599
        '%d months' % (minutes.to_f / 43200.0).round
      # 1 year to 2 years
      when 525600..1051199
        'about a year'
      else
        '%d years' % (minutes.to_f / 525600.0).round
      end
    end
    alias :time_ago_in_words :distance_of_time_in_words_to_now

    def strip_tags(html)
      html.gsub(/<.+?>/, '')
    end

    def number_with_delimiter(num)
      digits = num.to_s.split(//)
      groups = digits.reverse.in_groups_of(3).map {|g| g.join('') }
      groups.join(',').reverse
    end

  end
end
