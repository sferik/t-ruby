# encoding: utf-8
require 'helper'

describe T::CLI do

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

  describe "#account" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
    end
    it "should have the correct output" do
      @t.accounts
      $stdout.string.should == <<-eos.gsub(/^ {8}/, '')
        testcli
          abc123 (default)
      eos
    end
  end

  describe "#authorize" do
    before do
      @t.options = @t.options.merge("dry-run" => true)
      stub_post("/oauth/request_token").
        to_return(:body => fixture("request_token"))
    end
    it "should request the correct resource" do
      @t.authorize
      a_post("/oauth/request_token").
        should have_been_made
    end
    it "should not raise error" do
      lambda do
        @t.authorize
      end.should_not raise_error
    end
  end

  describe "#block" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.block("sferik")
      a_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.block("sferik")
      $stdout.string.should =~ /^@testcli blocked @sferik/
    end
  end

  describe "#direct_messages" do
    before do
      stub_get("/1/direct_messages.json").
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.direct_messages
      a_get("/1/direct_messages.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.direct_messages
      $stdout.string.should == <<-eos.gsub(/^/, ' ' * 6)
        sferik: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
        sferik: if you want to add me to your GroupMe group, my phone number is 415-312-2382 (about 1 year ago)
        sferik: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?  (about 1 year ago)
        sferik: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.  (about 1 year ago)
        sferik: Just checking in. How's everything going? (about 1 year ago)
        sferik: Any luck completing graphs this weekend? There have been lots of commits to RailsAdmin since summer ended but none from you. How's it going? (about 1 year ago)
        sferik: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
        sferik: Looks good to me. I'm going to pull in the change now. My only concern is that we don't have any tests for auth. (about 1 year ago)
        sferik: How are the graph enhancements coming? (about 1 year ago)
        sferik: Changes pushed. You should pull and re-bundle when you have a minute. (about 1 year ago)
        sferik: Glad to hear the new graphs are coming along. Can't wait to see them! (about 1 year ago)
        sferik: I figured out what was wrong with the tests: I accidentally unbundled webrat. The problem had nothing to do with rspec-rails. (about 1 year ago)
        sferik: After the upgrade 54/80 specs are failing. I'm working on fixing them now. (about 1 year ago)
        sferik: a new version of rspec-rails just shipped with some nice features and fixes http://github.com/rspec/rspec-rails/blob/master/History.md (about 1 year ago)
        sferik: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
        sferik: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
        sferik: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
        sferik: Can you try upgrading to 1.9.2 final, re-installing Bundler 1.0.0.rc.6 (don't remove 1.0.0) and see if you can reproduce the problem? (about 1 year ago)
        sferik: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
        sferik: Let's try to debug that problem during our session in 1.5 hours. In the mean time, try working on the graphs or internationalization. (about 1 year ago)
      eos
    end
  end

  describe "#dm" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.dm("pengwynn", "Creating a fixture for the Twitter gem")
      a_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.dm("pengwynn", "Creating a fixture for the Twitter gem")
      $stdout.string.chomp.should == "Direct Message sent from @testcli to @pengwynn (about 1 year ago)"
    end
  end

  describe "#favorite" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/favorites/create/27558893223.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.favorite("sferik")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
      a_post("/1/favorites/create/27558893223.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.favorite("sferik")
      $stdout.string.should =~ /^@testcli favorited @sferik's latest status: Ruby is the best programming language for hiding the ugly bits\.$/
    end
  end

  describe "#follow" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
      stub_post("/1/friendships/create.json").
        with(:body => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/users/recommendations.json").
        with(:query => {:limit => "2", :user_id => "7505382"}).
        to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.follow("sferik")
      a_post("/1/friendships/create.json").
        with(:body => {:screen_name => "sferik"}).
        should have_been_made
      a_get("/1/users/recommendations.json").
        with(:query => {:limit => "2", :user_id => "7505382"}).
        should have_been_made
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.follow("sferik")
      $stdout.string.should =~ /^@testcli is now following @sferik\.$/
      $stdout.string.should =~ /^Try following @jtrupiano or @mlroach\.$/
      $stdout.string.should =~ /^sferik: Ruby is the best programming language for hiding the ugly bits\. \(about 1 year ago\)$/
    end
  end

  describe "#get" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.get("sferik")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:screen_name => "sferik", :count => "1"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.get("sferik")
      $stdout.string.chomp.should == "Ruby is the best programming language for hiding the ugly bits. (about 1 year ago)"
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1/statuses/mentions.json").
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.mentions
      a_get("/1/statuses/mentions.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.mentions
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

  describe "#open" do
    it "should not raise error" do
      @t.options = @t.options.merge("dry-run" => true)
      lambda do
        @t.open("sferik")
      end.should_not raise_error
    end
  end

  describe "#reply" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
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
      @t.reply("sferik", "Testing")
      $stdout.string.chomp.should == "Reply created by @testcli (about 1 year ago)"
    end
  end

  describe "#retweet" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
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
      @t.retweet("sferik")
      $stdout.string.chomp.should == "@testcli retweeted @sferik's latest status: Ruby is the best programming language for hiding the ugly bits."
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
      @t.sent_messages
      $stdout.string.should == <<-eos.gsub(/^/, ' ' * 3)
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
      @t.stats("sferik")
      $stdout.string.should =~ /^Followers: 1,048$/
      $stdout.string.should =~ /^Following: 197$/
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
      @t.suggest
      $stdout.string.should =~ /^Try following @jtrupiano or @mlroach\.$/
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
      @t.timeline
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

  describe "#unfollow" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
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
      @t.unfollow("sferik")
      $stdout.string.should =~ /^@testcli is no longer following @sferik\.$/
    end
  end

  describe "#update" do
    before do
      @t.options = @t.options.merge("profile" => File.expand_path('../fixtures/.trc', __FILE__))
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
      @t.update("Testing")
      $stdout.string.chomp.should == "Tweet created by @testcli (about 1 year ago)"
    end
  end

  describe "#version" do
    it "should have the correct output" do
      @t.version
      $stdout.string.chomp.should == T::Version.to_s
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
      @t.whois("sferik")
      $stdout.string.should == <<-eos.gsub(/^ {8}/, '')
        Erik Michaels-Ober, since Jul 2007.
        bio: A mind forever voyaging through strange seas of thought, alone.
        location: San Francisco
        web: https://github.com/sferik
      eos
    end
  end

end
