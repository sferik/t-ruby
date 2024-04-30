module T
  class Version
    MAJOR = 4
    MINOR = 1
    PATCH = 1
    PRE = nil

    class << self
      # @return [String]
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join(".")
      end
    end
  end
end
