require 'tempfile'
require 'shellwords'

# Open a temp file and yield it to the block, closing it after
# @return [String] The path of the temp file
def temp_file
  file = Tempfile.new('t')
  yield file
ensure
  file.close(true) if file
end

def windows?
  !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/)
end

def editor
  return ENV['VISUAL'] if ENV['VISUAL'] && !ENV['VISUAL'].empty?
  return ENV['EDITOR'] if ENV['EDITOR'] && !ENV['EDITOR'].empty?
  if windows?
    'notepad'
  else
    %w(editor nano vi).detect do |editor|
      system("which #{editor} > /dev/null 2>&1")
    end
  end
end

def text
  temp_file do |f|
    system(*Shellwords.split([editor, f.path].join(' ')))
    File.read(f.path)
  end
end

puts text
