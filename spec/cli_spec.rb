# encoding: utf-8
require 'helper'

describe T::CLI do

  before do
    new_time = Time.local(2011, 11, 24, 16, 20, 0)
    Timecop.freeze(new_time)
    $stdout = StringIO.new
    @t = T::CLI.new
  end

  describe "#update" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "27558893223", :status => "@sferik Testing"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.reply("sferik", "Testing")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
      a_post("/1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "27558893223", :status => "@sferik Testing"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.reply("sferik", "Testing").string
      string.chomp.should == "Reply created (about 1 year ago)"
    end
  end

  describe "#retweet" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/statuses/retweet/27558893223.json").
        to_return(:body => fixture("retweet.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.retweet("sferik")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
      a_post("/1/statuses/retweet/27558893223.json").
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.retweet("sferik").string
      string.chomp.should == "You have retweeted @sferik's latest status: Ruby is the best programming language for hiding the ugly bits."
    end
  end

  describe "#sent_messages" do
    before do
      stub_get("/1/direct_messages/sent.json").
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.sent_messages
      a_get("/1/direct_messages/sent.json").
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.sent_messages.string
      string.should == <<-eos.gsub(/^/, ' ' * 3)
        hurrycane: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
     technoweenie: if you want to add me to your GroupMe group, my phone number is 415-312-2382 (about 1 year ago)
        hurrycane: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?  (about 1 year ago)
        hurrycane: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.  (about 1 year ago)
        hurrycane: Just checking in. How's everything going? (about 1 year ago)
        hurrycane: Any luck completing graphs this weekend? There have been lots of commits to RailsAdmin since summer ended but none from you. How's it going? (about 1 year ago)
        hurrycane: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
        hurrycane: Looks good to me. I'm going to pull in the change now. My only concern is that we don't have any tests for auth. (about 1 year ago)
        hurrycane: How are the graph enhancements coming? (about 1 year ago)
        hurrycane: Changes pushed. You should pull and re-bundle when you have a minute. (about 1 year ago)
        hurrycane: Glad to hear the new graphs are coming along. Can't wait to see them! (about 1 year ago)
        hurrycane: I figured out what was wrong with the tests: I accidentally unbundled webrat. The problem had nothing to do with rspec-rails. (about 1 year ago)
        hurrycane: After the upgrade 54/80 specs are failing. I'm working on fixing them now. (about 1 year ago)
        hurrycane: a new version of rspec-rails just shipped with some nice features and fixes http://github.com/rspec/rspec-rails/blob/master/History.md (about 1 year ago)
        hurrycane: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
        hurrycane: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
        hurrycane: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
        hurrycane: Can you try upgrading to 1.9.2 final, re-installing Bundler 1.0.0.rc.6 (don't remove 1.0.0) and see if you can reproduce the problem? (about 1 year ago)
        hurrycane: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
        hurrycane: Let's try to debug that problem during our session in 1.5 hours. In the mean time, try working on the graphs or internationalization. (about 1 year ago)
      eos
    end
  end

  describe "#stats" do
    before do
      stub_get("/1/users/show.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.stats("sferik")
      a_get("/1/users/show.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.stats("sferik").string
      string.should =~ /^Followers: 1,048$/
      string.should =~ /^Following: 197$/
    end
  end

  describe "#suggest" do
    before do
      stub_get("/1/users/recommendations.json").
        with(:query => {:limit => "2"}).
        to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.suggest
      a_get("/1/users/recommendations.json").
        with(:query => {:limit => "2"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.suggest.string
      string.should =~ /^Try following @jtrupiano or @mlroach\.$/
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1/statuses/home_timeline.json").
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.timeline
      a_get("/1/statuses/home_timeline.json").
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.timeline.string
      string.should == <<-eos.gsub(/^/, ' ' * 6)
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
      string.should =~ /^Unblocked @sferik$/
    end
  end

  describe "#unfavorite" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/favorites/destroy/27558893223.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.unfavorite("sferik")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
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
      string.should =~ /^You are no longer following @sferik\.$/
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
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.whois("sferik")
      a_get("/1/users/show.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      string = @t.whois("sferik").string
      string.should == <<-eos.gsub(/^ {8}/, '')
        Erik Michaels-Ober, since Jul 2007.
        bio: A mind forever voyaging through strange seas of thought, alone.
        location: San Francisco
        web: https://github.com/sferik
      eos
    end
  end

end
