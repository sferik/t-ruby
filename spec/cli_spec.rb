require 'helper'

describe T::CLI do

  before do
    $stdout = StringIO.new
    @t = T::CLI.new
  end

  describe "#version" do
    it "should output the gem version" do
      string = @t.version.string
      string.chomp.should == T::Version.to_s
    end
  end

  describe "#whois" do
    before do
      stub_get("/1/users/show.json").
        with(:query => {"screen_name" => "sferik"}).
        to_return(:body => fixture("sferik.json"))
    end
    it "should request the correct resource" do
      @t.whois("sferik")
      a_get("/1/users/show.json").
        with(:query => {"screen_name" => "sferik"}).
        should have_been_made
    end
    it "should output profile information about a user" do
      string = @t.whois("sferik").string
      string.should =~ /^Erik Michaels-Ober, since Jul 2007\.$/
      string.should =~ /^bio: /
      string.should =~ /^location: /
      string.should =~ /^web: /
    end
  end

end
