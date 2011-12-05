require 'helper'

describe T::CLI do

  before do
    $stdout = StringIO.new
    @t = T::CLI.new
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
    it "should output 'Tweet created'" do
      string = @t.update("Testing").string.chomp
      string.should =~ /^Tweet created/
    end
  end

  describe "#version" do
    it "should output the gem version" do
      string = @t.version.string.chomp
      string.should == T::Version.to_s
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
    it "should output profile information about a user" do
      string = @t.whois("sferik").string.chomp
      string.should =~ /^Erik Michaels-Ober, since Jul 2007\.$/
      string.should =~ /^bio: /
      string.should =~ /^location: /
      string.should =~ /^web: /
    end
  end

end
