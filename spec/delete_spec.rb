# encoding: utf-8
require 'helper'

describe T::Delete do

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

  describe "#block" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("block", "sferik")
      a_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("block", "sferik")
      $stdout.string.should =~ /^@testcli unblocked @sferik$/
    end
  end

  describe "#favorite" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/favorites/destroy/27558893223.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("favorite", "sferik")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
      a_delete("/1/favorites/destroy/27558893223.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("favorite", "sferik")
      $stdout.string.should =~ /^@testcli unfavorited @sferik's latest status: Ruby is the best programming language for hiding the ugly bits\.$/
    end
  end

end
