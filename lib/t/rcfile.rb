require 'singleton'
require 'yaml'

class RCFile
  FILE_NAME = '.trc'
  attr_reader :path

  include Singleton

  def initialize
    @path = File.join(File.expand_path("~"), FILE_NAME)
    @data = load
  end

  def [](username)
    profiles[username]
  end

  def []=(username, profile)
    profiles[username] ||= {}
    profiles[username].merge!(profile)
    write
  end

  def configuration
    @data['configuration']
  end

  def default_consumer_key
    profiles[default_profile[0]][default_profile[1]]['consumer_key'] if default_profile && profiles[default_profile[0]] && profiles[default_profile[0]][default_profile[1]]
  end

  def default_consumer_secret
    profiles[default_profile[0]][default_profile[1]]['consumer_secret'] if default_profile && profiles[default_profile[0]] && profiles[default_profile[0]][default_profile[1]]
  end

  def default_profile
    configuration['default_profile']
  end

  def default_profile=(profile)
    configuration['default_profile'] = [profile['username'], profile['consumer_key']]
    write
  end

  def default_secret
    profiles[default_profile[0]][default_profile[1]]['secret'] if default_profile && profiles[default_profile[0]] && profiles[default_profile[0]][default_profile[1]]
  end

  def default_token
    profiles[default_profile[0]][default_profile[1]]['token'] if default_profile && profiles[default_profile[0]] && profiles[default_profile[0]][default_profile[1]]
  end

  def delete
    File.delete(@path) if File.exist?(@path)
  end

  def empty?
    @data == default_structure
  end

  def load
    YAML.load_file(@path)
  rescue Errno::ENOENT
    default_structure
  end

  def path=(path)
    @path = path
    @data = load
    @path
  end

  def profiles
    @data['profiles']
  end

  def reset
    self.send(:initialize)
  end

private

  def default_structure
    {'configuration' => {}, 'profiles' => {}}
  end

  def write
    File.open(@path, 'w') do |rcfile|
      rcfile.write @data.to_yaml
    end
  end

end
