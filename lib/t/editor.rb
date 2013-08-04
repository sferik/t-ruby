require 'tempfile'
require 'shellwords'

module T
  class Editor
    class << self

      def gets
        file = tempfile
        edit(file.path)
        File.read(file).strip
      ensure
        file.close
        file.unlink
      end

      def tempfile
        Tempfile.new("TWEET_EDITMSG")
      end

      def edit(path)
        system(Shellwords.join([editor, path]))
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
