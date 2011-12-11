# encoding: utf-8
require 'helper'

describe T::CLI::Unfollow::All do

  before do
    @t = T::CLI.new
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#nonfollowers" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/friendships/destroy.json").
        with(:query => {:user_id => "7505382"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.unfollow("all", "nonfollowers")
      a_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_delete("/1/friendships/destroy.json").
        with(:query => {:user_id => "7505382"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.unfollow("all", "nonfollowers")
      $stdout.string.should =~ /^@testcli is no longer following @sferik\.$/
    end
  end

end
