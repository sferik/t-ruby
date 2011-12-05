require 'helper'

describe T::CLI do

  before do
    new_time = Time.local(2011, 11, 24, 16, 20, 0)
    Timecop.freeze(new_time)
    $stdout = StringIO.new
    @t = T::CLI.new
  end

  describe "#unblock" do
    before do
      stub_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.unblock("sferik")
      a_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.unblock("sferik").string
      string.should =~ /^Unblocked @sferik/
    end
  end

  describe "#unfavorite" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/favorites/destroy/27558893223.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.unfavorite("sferik")
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
      a_delete("/1/favorites/destroy/27558893223.json").
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.unfavorite("sferik").string
      string.chomp.should == "You have unfavorited @sferik's latest status: Ruby is the best programming language for hiding the ugly bits."
    end
  end

  describe "#unfollow" do
    before do
      stub_delete("/1/friendships/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.unfollow("sferik")
      a_delete("/1/friendships/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.unfollow("sferik").string
      string.should =~ /^You are no longer following @sferik\./
    end
  end

  describe "#update" do
    before do
      stub_post("/1/statuses/update.json").
        with(:body => {:status => "Testing"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.update("Testing")
      a_post("/1/statuses/update.json").
        with(:body => {:status => "Testing"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.update("Testing").string
      string.chomp.should == "Tweet created (about 1 year ago)"
    end
  end

  describe "#version" do
    it "should have the correct output" do
      string = @t.version.string
      string.chomp.should == T::Version.to_s
    end
  end

  describe "#whois" do
    before do
      stub_get("/1/users/show.json").
        with(:query => {"screen_name" => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.whois("sferik")
      a_get("/1/users/show.json").
        with(:query => {"screen_name" => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.whois("sferik").string
      string.should == <<-EOF.gsub(/^ {8}/, '')
        Erik Michaels-Ober, since Jul 2007.
        bio: A mind forever voyaging through strange seas of thought, alone.
        location: San Francisco
        web: https://github.com/sferik
      EOF
    end
  end

end
