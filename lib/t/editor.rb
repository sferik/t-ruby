module T
  class Editor
    class << self
      TMP_TWEET = "/tmp/TWEET_MESSAGE"
      PREFILLS = {
        :update => "\n# Enter your tweet above."
      }

      def gets(operation = :update)
        File.open TMP_TWEET, 'a+' do |f|
          f << PREFILLS[operation] if File.zero? TMP_TWEET
          f.rewind
          system "#{editor} #{TMP_TWEET}"
          return File.read(TMP_TWEET).gsub(/(?:^#.*$\n?)+\s*\z/, '').strip
        end
      end

      def editor
        editor   = ENV['VISUAL']
        editor ||= ENV['EDITOR']
        editor ||= 'vi'
      end
    end
  end
end
