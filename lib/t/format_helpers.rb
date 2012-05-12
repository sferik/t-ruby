require 'date'

module T
  module FormatHelpers
    private

    # https://github.com/rails/rails/blob/bd8a970/actionpack/lib/action_view/helpers/date_helper.rb
    def distance_of_time_in_words_to_now(from_time)
      to_time = Time.now
      seconds = (to_time - from_time).abs
      case (minutes = seconds / 60)
      when 0             then 'less than a minute'
      when 1             then '1 minute'
      when 2..44         then '%d minutes' % minutes
      when 45..89        then 'about 1 hour'
      when 90..1439      then 'about %d hours' % (minutes.to_f / 60.0).round
      when 1440..2519    then '1 day'
      when 2520..43199   then '%d days' % (minutes.to_f / 1440.0).round
      when 43200..86399  then 'about 1 month'
      when 86400..525599 then '%d months' % (minutes.to_f / 43200.0).round
      else
        fyear = from_time.year
        fyear += 1 if from_time.month >= 3
        tyear = to_time.year
        tyear -= 1 if to_time.month < 3
        leap_years = (fyear > tyear) ? 0 : (fyear..tyear).count{|x| Date.leap?(x)}
        minute_offset_for_leap_year = leap_years * 1440
        minutes_with_offset         = minutes - minute_offset_for_leap_year
        remainder                   = (minutes_with_offset % 525600)
        distance_in_years           = (minutes_with_offset / 525600)
        if remainder < 131400
          pluralize distance_in_years, 'about %d year'
        elsif remainder < 394200
          pluralize distance_in_years, 'over %d year'
        else
          pluralize distance_in_years + 1, 'almost %d year'
        end
      end
    end
    alias time_ago_in_words distance_of_time_in_words_to_now

    def pluralize(count, word)
      word += 's' if count.to_i > 1
      if word.include? '%'
        word % count
      else
        "%d #{word}" % count
      end
    end

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
