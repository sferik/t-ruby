module T
  class Version
    class << self

      # @return [Integer]
      def major
        1
      end

      # @return [Integer]
      def minor
        7
      end

      # @return [Integer]
      def patch
        2
      end

      # @return [String, NilClass]
      def pre
        nil
      end

      # @return [String]
      def to_s
        [major, minor, patch, pre].compact.join('.')
      end

    end
  end
end
