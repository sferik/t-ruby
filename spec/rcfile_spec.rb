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
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile['sferik'].keys.should == ['abc123']
    end
  end

  describe '#[]=' do
    it 'should add a profile for a user' do
      rcfile = RCFile.instance
      rcfile.path = '/tmp/trc'
      rcfile['sferik'] = {
        'abc123' => {
          :username => 'sferik',
          :consumer_key => 'abc123',
          :consumer_secret => 'def456',
          :token => 'ghi789',
          :secret => 'jkl012',
        }
      }
      rcfile['sferik'].keys.should == ['abc123']
    end
    it 'should write the data to disk' do
      rcfile = RCFile.instance
      rcfile.path = '/tmp/trc'
      rcfile['sferik'] = {
        'abc123' => {
          :username => 'sferik',
          :consumer_key => 'abc123',
          :consumer_secret => 'def456',
          :token => 'ghi789',
          :secret => 'jkl012',
        }
      }
      rcfile.load
      rcfile['sferik'].keys.should == ['abc123']
      rcfile.delete
    end
  end

  describe '#configuration' do
    it 'should return configuration' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.configuration.keys.should == ['default_profile']
    end
  end

  describe '#default_consumer_key' do
    it 'should return default consumer key' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.default_consumer_key.should == 'abc123'
    end
  end

  describe '#default_consumer_secret' do
    it 'should return default consumer secret' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.default_consumer_secret.should == 'asdfasd223sd2'
    end
  end

  describe '#default_profile' do
    it 'should return default profile' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.default_profile.should == ['sferik', 'abc123']
    end
  end

  describe '#default_profile=' do
    it 'should set default profile' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('/tmp/trc', __FILE__)
      rcfile.load
      rcfile.delete
      rcfile.default_profile = {'username' => 'sferik', 'consumer_key' => 'abc123'}
      rcfile.default_profile.should == ['sferik', 'abc123']
    end
    it 'should write the data to disk' do
      rcfile = RCFile.instance
      rcfile.path = '/tmp/trc'
      rcfile.default_profile = {'username' => 'sferik', 'consumer_key' => 'abc123'}
      rcfile.load
      rcfile.default_profile.should == ['sferik', 'abc123']
      rcfile.delete
    end
  end

  describe '#default_token' do
    it 'should return default token' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.default_token.should == '7505382-cebdct6bwobn'
    end
  end

  describe '#default_secret' do
    it 'should return default secret' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.default_secret.should == 'epzrjvxtumoc'
    end
  end

  describe '#delete' do
    it 'should delete the rcfile' do
      path = '/tmp/trc'
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
        rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
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
        rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
        rcfile.load['profiles']['sferik']['abc123']['username'].should == 'sferik'
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
      rcfile.path = '/tmp/trc'
      rcfile.path.should == '/tmp/trc'
    end
    it 'should reload data' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile['sferik']['abc123']['username'].should == 'sferik'
    end
  end

  describe '#profiles' do
    it 'should return profiles' do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      rcfile.profiles.keys.should == ['sferik']
    end
  end

end
