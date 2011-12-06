# encoding: utf-8
require 'helper'

describe T::Set do

  before do
    @t = T::CLI.new
    Timecop.freeze(Time.local(2011, 11, 24, 16, 20, 0))
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#bio" do
    before do
      stub_post("/1/account/update_profile.json").
        with(:body => {:description => "A mind forever voyaging through strange seas of thought, alone."}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.set("bio", "A mind forever voyaging through strange seas of thought, alone.")
      a_post("/1/account/update_profile.json").
        with(:body => {:description => "A mind forever voyaging through strange seas of thought, alone."}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.set("bio", "A mind forever voyaging through strange seas of thought, alone.")
      $stdout.string.chomp.should == "Bio has been changed."
    end
  end

  describe "#bio" do
    it "should have the correct output" do
      rcfile = RCFile.instance
      rcfile.path = File.expand_path('../fixtures/.trc', __FILE__)
      @t.set("default", "testcli", "abc123")
      $stdout.string.chomp.should == "Default account has been changed."
    end
  end

  describe "#language" do
    before do
      stub_post("/1/account/settings.json").
        with(:body => {:lang => "en"}).
        to_return(:body => fixture("settings.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.set("language", "en")
      a_post("/1/account/settings.json").
        with(:body => {:lang => "en"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.set("language", "en")
      $stdout.string.chomp.should == "Language has been changed."
    end
  end

  describe "#location" do
    before do
      stub_post("/1/account/update_profile.json").
        with(:body => {:location => "San Francisco"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.set("location", "San Francisco")
      a_post("/1/account/update_profile.json").
        with(:body => {:location => "San Francisco"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.set("location", "San Francisco")
      $stdout.string.chomp.should == "Location has been changed."
    end
  end

  describe "#name" do
    before do
      stub_post("/1/account/update_profile.json").
        with(:body => {:name => "Erik Michaels-Ober"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.set("name", "Erik Michaels-Ober")
      a_post("/1/account/update_profile.json").
        with(:body => {:name => "Erik Michaels-Ober"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.set("name", "Erik Michaels-Ober")
      $stdout.string.chomp.should == "Name has been changed."
    end
  end

  describe "#url" do
    before do
      stub_post("/1/account/update_profile.json").
        with(:body => {:url => "https://github.com/sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.set("url", "https://github.com/sferik")
      a_post("/1/account/update_profile.json").
        with(:body => {:url => "https://github.com/sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.set("url", "https://github.com/sferik")
      $stdout.string.chomp.should == "URL has been changed."
    end
  end

end
