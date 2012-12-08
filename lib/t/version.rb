module T
  class Version

    # @return [Integer]
    def self.major
      1
    end

    # @return [Integer]
    def self.minor
      5
    end

    # @return [Integer]
    def self.patch
      1
    end

    # @return [String, NilClass]
    def self.pre
      nil
    end

    # @return [String]
    def self.to_s
      [major, minor, patch, pre].compact.join('.')
    end

  end
end
