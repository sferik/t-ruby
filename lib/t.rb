require 'active_support/string_inquirer'
require 't/cli'

module T
  class << self

    def env
      @env
    end

    def env=(environment)
      @env = ActiveSupport::StringInquirer.new(environment)
    end

  end
end
