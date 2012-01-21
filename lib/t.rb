require 'active_support/string_inquirer'
require 't/cli'

module T
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new("development")
    end

    def env=(environment)
      @env = ActiveSupport::StringInquirer.new(environment)
    end
  end
end
