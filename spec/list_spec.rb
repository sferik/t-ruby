# encoding: utf-8
require 'helper'

describe T::List do

  before do
    rcfile = RCFile.instance
    rcfile.path = fixture_path + "/.trc"
    @list = T::List.new
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
    Timecop.freeze(Time.utc(2011, 11, 24, 16, 20, 0))
  end

  after do
    Timecop.return
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#add" do
    before do
      @list.options = @list.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/lists/members/create_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @list.add("presidents", "sferik")
      a_get("/1/account/verify_credentials.json").
        should have_been_made
      a_post("/1/lists/members/create_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @list.add("presidents", "sferik")
      $stdout.string.should =~ /@testcli added 1 user to the list "presidents"\./
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:status => 502)
        lambda do
          @list.add("presidents", "sferik")
        end.should raise_error("Twitter is down or being upgraded.")
        a_post("/1/lists/members/create_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#create" do
    before do
      @list.options = @list.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/lists/create.json").
        with(:body => {:name => "presidents"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @list.create("presidents")
      a_post("/1/lists/create.json").
        with(:body => {:name => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @list.create("presidents")
      $stdout.string.chomp.should == "@testcli created the list \"presidents\"."
    end
  end

  describe "#remove" do
    before do
      @list.options = @list.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      stub_post("/1/lists/members/destroy_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @list.remove("presidents", "sferik")
      a_get("/1/account/verify_credentials.json").
        should have_been_made
      a_post("/1/lists/members/destroy_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      stub_post("/1/lists/members/destroy_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @list.remove("presidents", "sferik")
      $stdout.string.should =~ /@testcli removed 1 user from the list "presidents"\./
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_post("/1/lists/members/destroy_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:status => 502)
        lambda do
          @list.remove("presidents", "sferik")
        end.should raise_error("Twitter is down or being upgraded.")
        a_post("/1/lists/members/destroy_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1/lists/statuses.json").
        with(:query => {:owner_screen_name => "testcli", :per_page => "20", :slug => "presidents", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @list.timeline("presidents")
      a_get("/1/lists/statuses.json").
        with(:query => {:owner_screen_name => "testcli", :per_page => "20", :slug => "presidents", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @list.timeline("presidents")
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
    context "long" do
      before do
        @list.options = @list.options.merge(:long => true)
      end
      it "should list in long format" do
        @list.timeline("presidents")
        $stdout.string.should == <<-eos
ID           Created at    Screen name  Text
27558893223  Oct 16  2010  sferik       Ruby is the best programming language for hiding the ugly bits.
27467028175  Oct 15  2010  sferik       There are 1.3 billion people in China; when people say there are 1 billion they are rounding off the entire population of the United States.
27068258331  Oct 11  2010  sferik       The new Windows Phone campaign is the best advertising from Microsoft since "Start Me Up" (1995). Great work by CP+B. http://t.co/tIzxopI
26959930192  Oct 10  2010  sferik       Fear not to sow seeds because of the birds. http://twitpic.com/2wg621
26503221778  Oct  5  2010  sferik       Speaking of things that are maddening: the interview with the Wall Street guys on the most recent This American Life http://bit.ly/af9pSD
25836892941  Sep 28  2010  sferik       Holy cow! RailsAdmin is up to 200 watchers (from 100 yesterday). http://github.com/sferik/rails_admin
25732982065  Sep 27  2010  sferik       Kind of cool that Facebook acts as a mirror for open-source projects that they use or like http://mirror.facebook.net/
25693598875  Sep 27  2010  sferik       RailsAdmin already has 100 watchers, 12 forks, and 6 contributors in less than 2 months. Let's keep the momentum going! http://bit.ly/cCMMqD
24443017910  Sep 13  2010  sferik       This week's This American Life is amazing. @JoeLipari is an American hero. http://bit.ly/d9RbnB
24158227743  Sep 10  2010  sferik       RT @polyseme: OH: shofars should be called jewvuzelas.
24126395365  Sep 10  2010  sferik       Spent this morning fixing broken windows in RailsAdmin http://github.com/sferik/rails_admin/compare/ab6c598...0e3770f
24126047148  Sep 10  2010  sferik       I'm a big believer that the broken windows theory applies to software development http://en.wikipedia.org/wiki/Broken_windows_theory
24028079777  Sep  9  2010  sferik       I hope you idiots are happy with your piece of shit Android phones. http://www.apple.com/pr/library/2010/09/09statement.html
22728299854  Sep  1  2010  sferik       Ping: kills MySpace dead.
22727444431  Sep  1  2010  sferik       Crazy that iTunes Ping didn't leak a drop.
22683247815  Aug 31  2010  sferik       The plot thickens http://twitpic.com/2k5lt2
22305399947  Aug 27  2010  sferik       140 Proof Provides A Piece Of The Twitter Advertising Puzzle http://t.co/R2cUSDe via @techcrunch
22303907694  Aug 27  2010  sferik       Try as you may http://www.thedoghousediaries.com/?p=1940
21538122473  Aug 18  2010  sferik       I know @SarahPalinUSA has a right to use Twitter, but should she?
        eos
      end
    end
  end

end
