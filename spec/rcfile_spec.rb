# encoding: utf-8
require 'helper'

describe RCFile do

  after do
    RCFile.instance.reset
  end

  it 'should be a singleton class' do
    RCFile.should be_a Class
    lambda do
      RCFile.new
    end.should raise_error(NoMethodError, /private method `new' called/)
  end

  describe '#[]' do
    it 'should return the profiles for a user' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile['testcli'].keys.should == ['abc123']
    end
  end

  describe '#[]=' do
    it 'should add a profile for a user' do
      rcfile = RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile['testcli'] = {
        'abc123' => {
          :username => 'testcli',
          :consumer_key => 'abc123',
          :consumer_secret => 'def456',
          :token => 'ghi789',
          :secret => 'jkl012',
        }
      }
      rcfile['testcli'].keys.should == ['abc123']
    end
    it 'should write the data to disk' do
      rcfile = RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile['testcli'] = {
        'abc123' => {
          :username => 'testcli',
          :consumer_key => 'abc123',
          :consumer_secret => 'def456',
          :token => 'ghi789',
          :secret => 'jkl012',
        }
      }
      rcfile['testcli'].keys.should == ['abc123']
    end
  end

  describe '#configuration' do
    it 'should return configuration' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.configuration.keys.should == ['default_profile']
    end
  end

  describe '#default_consumer_key' do
    it 'should return default consumer key' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.default_consumer_key.should == 'abc123'
    end
  end

  describe '#default_consumer_secret' do
    it 'should return default consumer secret' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.default_consumer_secret.should == 'asdfasd223sd2'
    end
  end

  describe '#default_profile' do
    it 'should return default profile' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.default_profile.should == ['testcli', 'abc123']
    end
  end

  describe '#default_profile=' do
    it 'should set default profile' do
      rcfile = RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile.default_profile = {'username' => 'testcli', 'consumer_key' => 'abc123'}
      rcfile.default_profile.should == ['testcli', 'abc123']
    end
    it 'should write the data to disk' do
      rcfile = RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile.default_profile = {'username' => 'testcli', 'consumer_key' => 'abc123'}
      rcfile.default_profile.should == ['testcli', 'abc123']
    end
  end

  describe '#default_token' do
    it 'should return default token' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.default_token.should == '428004849-cebdct6bwobn'
    end
  end

  describe '#default_secret' do
    it 'should return default secret' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.default_secret.should == 'epzrjvxtumoc'
    end
  end

  describe '#delete' do
    it 'should delete the rcfile' do
      path = project_path + "/tmp/trc"
      FileUtils.touch(path)
      File.exist?(path).should be_true
      rcfile = RCFile.instance
      rcfile.path = path
      rcfile.delete
      File.exist?(path).should be_false
    end
  end

  describe '#empty?' do
    context 'when a non-empty file exists' do
      it 'should return false' do
        rcfile = RCFile.instance
        rcfile.path = fixture_path + "/.trc"
        rcfile.empty?.should be_false
      end
    end
    context 'when file does not exist at path' do
      it 'should return true' do
        rcfile = RCFile.instance
        rcfile.path = File.expand_path('../fixtures/foo', __FILE__)
        rcfile.empty?.should be_true
      end
    end
  end

  describe '#load' do
    context 'when file exists at path' do
      it 'should load data from file' do
        rcfile = RCFile.instance
        rcfile.path = fixture_path + "/.trc"
        rcfile.load['profiles']['testcli']['abc123']['username'].should == 'testcli'
      end
    end
    context 'when file does not exist at path' do
      it 'should load default structure' do
        rcfile = RCFile.instance
        rcfile.path = File.expand_path('../fixtures/foo', __FILE__)
        rcfile.load.keys.sort.should == ['configuration', 'profiles']
      end
    end
  end

  describe '#path' do
    it 'should default to ~/.trc' do
      RCFile.instance.path.should == File.join(File.expand_path('~'), '.trc')
    end
  end

  describe '#path=' do
    it 'should override path' do
      rcfile = RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile.path.should == project_path + "/tmp/trc"
    end
    it 'should reload data' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile['testcli']['abc123']['username'].should == 'testcli'
    end
  end

  describe '#profiles' do
    it 'should return profiles' do
      rcfile = RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      rcfile.profiles.keys.should == ['testcli']
    end
  end

end
