# encoding: utf-8
require 'helper'

describe T::CLI::List do

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

  describe "#create" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/lists/create.json").
        with(:body => {:name => "presidents"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.list("create", "presidents")
      a_post("/1/lists/create.json").
        with(:body => {:name => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.list("create", "presidents")
      $stdout.string.chomp.should == "@testcli created the list \"presidents\"."
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/lists/statuses.json").
        with(:query => {:owner_screen_name => "sferik", :per_page => "20", :slug => "presidents"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.list("timeline", "presidents")
      a_get("/1/account/verify_credentials.json").
        should have_been_made
      a_get("/1/lists/statuses.json").
        with(:query => {:owner_screen_name => "sferik", :per_page => "20", :slug => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.list("timeline", "presidents")
      $stdout.string.should == <<-eos.gsub(/^/, ' ' * 6)
        sferik: Ruby is the best programming language for hiding the ugly bits. (about 1 year ago)
        sferik: There are 1.3 billion people in China; when people say there are 1 billion they are rounding off the entire population of the United States. (about 1 year ago)
        sferik: The new Windows Phone campaign is the best advertising from Microsoft since "Start Me Up" (1995). Great work by CP+B. http://t.co/tIzxopI (about 1 year ago)
        sferik: Fear not to sow seeds because of the birds. http://twitpic.com/2wg621 (about 1 year ago)
        sferik: Speaking of things that are maddening: the interview with the Wall Street guys on the most recent This American Life http://bit.ly/af9pSD (about 1 year ago)
        sferik: Holy cow! RailsAdmin is up to 200 watchers (from 100 yesterday). http://github.com/sferik/rails_admin (about 1 year ago)
        sferik: Kind of cool that Facebook acts as a mirror for open-source projects that they use or like http://mirror.facebook.net/ (about 1 year ago)
        sferik: RailsAdmin already has 100 watchers, 12 forks, and 6 contributors in less than 2 months. Let's keep the momentum going! http://bit.ly/cCMMqD (about 1 year ago)
        sferik: This week's This American Life is amazing. @JoeLipari is an American hero. http://bit.ly/d9RbnB (about 1 year ago)
        sferik: RT @polyseme: OH: shofars should be called jewvuzelas. (about 1 year ago)
        sferik: Spent this morning fixing broken windows in RailsAdmin http://github.com/sferik/rails_admin/compare/ab6c598...0e3770f (about 1 year ago)
        sferik: I'm a big believer that the broken windows theory applies to software development http://en.wikipedia.org/wiki/Broken_windows_theory (about 1 year ago)
        sferik: I hope you idiots are happy with your piece of shit Android phones. http://www.apple.com/pr/library/2010/09/09statement.html (about 1 year ago)
        sferik: Ping: kills MySpace dead. (about 1 year ago)
        sferik: Crazy that iTunes Ping didn't leak a drop. (about 1 year ago)
        sferik: The plot thickens http://twitpic.com/2k5lt2 (about 1 year ago)
        sferik: 140 Proof Provides A Piece Of The Twitter Advertising Puzzle http://t.co/R2cUSDe via @techcrunch (about 1 year ago)
        sferik: Try as you may http://www.thedoghousediaries.com/?p=1940 (about 1 year ago)
        sferik: I know @SarahPalinUSA has a right to use Twitter, but should she? (over 1 year ago)
      eos
    end
  end

end
