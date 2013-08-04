require 'tempfile'
require 'shellwords'

module T
  class Editor
    class << self
      PREFILLS = {
        :update => "\n# Enter your tweet above."
      }

      def gets(operation = :update)
        f = tempfile(PREFILLS[operation])
        edit(f.path)
        f.read.gsub(/(?:^#.*$\n?)+\s*\z/, '').strip
      end

      def tempfile(prefill = PREFILLS[:update])
        f = Tempfile.new("TWEET_MESSAGE")
        f << prefill
        f.rewind
        f
      end

      def edit(path)
        system Shellwords.join([editor, path])
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
