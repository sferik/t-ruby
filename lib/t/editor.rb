require 'tempfile'
require 'shellwords'

module T
  class Editor
    class << self
      PREFILLS = {
        :update => "\n# Enter your tweet above."
      }

      def gets(operation = :update)
        f = Tempfile.new("TWEET_MESSAGE")
        f << PREFILLS[operation]
        f.rewind
        system Shellwords.join([editor, f.path])
        f.read.gsub(/(?:^#.*$\n?)+\s*\z/, '').strip
      end

      def editor
        editor   = ENV['VISUAL']
        editor ||= ENV['EDITOR']
        editor ||= system_editor
      end

      def system_editor
        if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
          'notepad'
        else
          'vi'
        end
      end
    end
  end
end
