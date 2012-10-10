# encoding: utf-8
require 'helper'

describe T::RCFile do

  after :each do
    T::RCFile.instance.reset
    File.delete(project_path + "/tmp/trc") if File.exist?(project_path + "/tmp/trc")
  end

  it "is a singleton" do
    expect(T::RCFile).to be_a Class
    expect do
      T::RCFile.new
    end.to raise_error(NoMethodError, /private method `new' called/)
  end

  describe "#[]" do
    it "should return the profiles for a user" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile['testcli'].keys).to eq ['abc123']
    end
  end

  describe "#[]=" do
    it "should add a profile for a user" do
      rcfile = T::RCFile.instance
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
      expect(rcfile['testcli'].keys).to eq ['abc123']
    end
    it "should write the data to disk" do
      rcfile = T::RCFile.instance
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
      expect(rcfile['testcli'].keys).to eq ['abc123']
    end
    it "should not be world readable or writable" do
      rcfile = T::RCFile.instance
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
      expect(File.stat(rcfile.path).mode).to eq 33152
    end
  end

  describe "#configuration" do
    it "should return configuration" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.configuration.keys).to eq ['default_profile']
    end
  end

  describe "#active_consumer_key" do
    it "should return default consumer key" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.active_consumer_key).to eq 'abc123'
    end
  end

  describe "#active_consumer_secret" do
    it "should return default consumer secret" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.active_consumer_secret).to eq 'asdfasd223sd2'
    end
  end

  describe "#active_profile" do
    it "should return default profile" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.active_profile).to eq ['testcli', 'abc123']
    end
  end

  describe "#active_profile=" do
    it "should set default profile" do
      rcfile = T::RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile.active_profile = {'username' => 'testcli', 'consumer_key' => 'abc123'}
      expect(rcfile.active_profile).to eq ['testcli', 'abc123']
    end
    it "should write the data to disk" do
      rcfile = T::RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      rcfile.active_profile = {'username' => 'testcli', 'consumer_key' => 'abc123'}
      expect(rcfile.active_profile).to eq ['testcli', 'abc123']
    end
  end

  describe "#active_token" do
    it "should return default token" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.active_token).to eq '428004849-cebdct6bwobn'
    end
  end

  describe "#active_secret" do
    it "should return default secret" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.active_secret).to eq 'epzrjvxtumoc'
    end
  end

  describe "#delete" do
    it "should delete the rcfile" do
      path = project_path + "/tmp/trc"
      File.open(path, 'w'){|file| file.write(YAML.dump({}))}
      expect(File.exist?(path)).to be_true
      rcfile = T::RCFile.instance
      rcfile.path = path
      rcfile.delete
      expect(File.exist?(path)).to be_false
    end
  end

  describe "#empty?" do
    context "when a non-empty file exists" do
      it "should return false" do
        rcfile = T::RCFile.instance
        rcfile.path = fixture_path + "/.trc"
        expect(rcfile.empty?).to be_false
      end
    end
    context "when file does not exist at path" do
      it "should return true" do
        rcfile = T::RCFile.instance
        rcfile.path = File.expand_path('../fixtures/foo', __FILE__)
        expect(rcfile.empty?).to be_true
      end
    end
  end

  describe "#load_file" do
    context "when file exists at path" do
      it "should load data from file" do
        rcfile = T::RCFile.instance
        rcfile.path = fixture_path + "/.trc"
        expect(rcfile.load_file['profiles']['testcli']['abc123']['username']).to eq 'testcli'
      end
    end
    context "when file does not exist at path" do
      it "should load default structure" do
        rcfile = T::RCFile.instance
        rcfile.path = File.expand_path('../fixtures/foo', __FILE__)
        expect(rcfile.load_file.keys.sort).to eq ['configuration', 'profiles']
      end
    end
  end

  describe "#path" do
    it "should default to ~/.trc" do
      expect(T::RCFile.instance.path).to eq File.join(File.expand_path('~'), '.trc')
    end
  end

  describe "#path=" do
    it "should override path" do
      rcfile = T::RCFile.instance
      rcfile.path = project_path + "/tmp/trc"
      expect(rcfile.path).to eq project_path + "/tmp/trc"
    end
    it "should reload data" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile['testcli']['abc123']['username']).to eq 'testcli'
    end
  end

  describe "#profiles" do
    it "should return profiles" do
      rcfile = T::RCFile.instance
      rcfile.path = fixture_path + "/.trc"
      expect(rcfile.profiles.keys).to eq ['testcli']
    end
  end

end
