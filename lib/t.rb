require 'time'
require 'active_support/string_inquirer'
require 't/cli'

module T
  class << self

    attr_reader :env

    def env=(environment)
      @env = ActiveSupport::StringInquirer.new(environment)
    end

    # Convert time to local time by applying the `utc_offset` setting.
    def local_time(time)
      utc_offset ? (time.utc + utc_offset) : time.localtime
    end

    # UTC offset in seconds to apply time instances before displaying.
    # If not set, time instances are displayed in default local time.
    attr_reader :utc_offset

    def utc_offset=(offset)
      @utc_offset = case offset
                    when String   then Time.zone_offset(offset)
                    when NilClass then nil
                    else offset.to_i
                    end
    end

  end
end
