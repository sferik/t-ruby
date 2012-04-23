# encoding: utf-8
require 'helper'

describe T::CLI do

  before do
    rcfile = RCFile.instance
    rcfile.path = fixture_path + "/.trc"
    @t = T::CLI.new
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

  describe "#account" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
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
      @t.options = @t.options.merge(:profile => File.expand_path('/tmp/trc', __FILE__), :consumer_key => "abc123", :consumer_secret => "asdfasd223sd2", :prompt => true, :dry_run => true)
      stub_post("/oauth/request_token").
        to_return(:body => fixture("request_token"))
      stub_post("/oauth/access_token").
        to_return(:body => fixture("access_token"))
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      $stdout.should_receive(:print).with("Press [Enter] to open the Twitter app authorization page. ")
      $stdin.should_receive(:gets).and_return("\n")
      $stdout.should_receive(:print).with("Paste in the supplied PIN: ")
      $stdin.should_receive(:gets).and_return("1234567890")
      @t.authorize
      a_post("/oauth/request_token").
        should have_been_made
      a_post("/oauth/access_token").
        should have_been_made
      a_get("/1/account/verify_credentials.json").
        should have_been_made
    end
    it "should not raise error" do
      lambda do
        $stdout.should_receive(:print).with("Press [Enter] to open the Twitter app authorization page. ")
        $stdin.should_receive(:gets).and_return("\n")
        $stdout.should_receive(:print).with("Paste in the supplied PIN: ")
        $stdin.should_receive(:gets).and_return("1234567890")
        @t.authorize
      end.should_not raise_error
    end
  end

  describe "#block" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.block("sferik")
      a_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
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
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.direct_messages
      a_get("/1/direct_messages.json").
        with(:query => {:count => "20", :include_entities => "false"}).
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

  describe "#direct_messages_sent" do
    before do
      stub_get("/1/direct_messages/sent.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.direct_messages_sent
      a_get("/1/direct_messages/sent.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.direct_messages_sent
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

  describe "#dm" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem", :include_entities => "false"}).
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.dm("pengwynn", "Creating a fixture for the Twitter gem")
      a_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.dm("pengwynn", "Creating a fixture for the Twitter gem")
      $stdout.string.chomp.should == "Direct Message sent from @testcli to @pengwynn (about 1 year ago)."
    end
  end

  describe "#favorite" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/favorites/create/26755176471724032.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.favorite("26755176471724032")
      a_post("/1/favorites/create/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.favorite("26755176471724032")
      $stdout.string.should =~ /^@testcli favorited @sferik's status: "@noradio working on implementing #NewTwitter API methods in the twitter gem\. Twurl is making it easy\. Thank you!"$/
    end
  end

  describe "#favorites" do
    before do
      stub_get("/1/favorites.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.favorites
      a_get("/1/favorites.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.favorites
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

  describe "#follow" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      it "should exit" do
        lambda do
          @t.follow
        end.should raise_error
      end
    end
    context "one user" do
      it "should request the correct resource" do
        stub_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.follow("sferik")
        a_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.follow("sferik")
        $stdout.string.should =~ /^@testcli is now following 1 more user\.$/
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_post("/1/friendships/create.json").
            with(:body => {:screen_name => "sferik", :include_entities => "false"}).
            to_return(:status => 502)
          lambda do
            @t.follow("sferik")
          end.should raise_error("Twitter is down or being upgraded.")
          a_post("/1/friendships/create.json").
            with(:body => {:screen_name => "sferik", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#followings" do
    before do
      stub_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.followings
      a_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.followings
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
  end

  describe "#followers" do
    before do
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.followers
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.followers
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
  end

  describe "#friends" do
    before do
      stub_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.friends
      a_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.friends
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
  end

  describe "#leaders" do
    before do
      stub_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.leaders
      a_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.leaders
      $stdout.string.chomp.rstrip.should == ""
    end
  end

  describe "#members" do
    before do
      stub_get("/1/lists/members.json").
        with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
        to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.members("sferik", "presidents")
      a_get("/1/lists/members.json").
        with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.members("sferik", "presidents")
      $stdout.string.chomp.should == ""
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1/statuses/mentions.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.mentions
      a_get("/1/statuses/mentions.json").
        with(:query => {:count => "20", :include_entities => "false"}).
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
    before do
      @t.options = @t.options.merge(:dry_run => true)
    end
    it "should not raise error" do
      lambda do
        @t.open("sferik")
      end.should_not raise_error
    end
  end

  describe "#reply" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc", :location => true)
      stub_get("/1/statuses/show/25938088801.json").
        with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "25938088801", :status => "@sferik Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_request(:get, "http://checkip.dyndns.org/").
        to_return(:body => fixture("checkip.html"), :headers => {:content_type => "text/html"})
      stub_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        to_return(:body => fixture("xml.gp"), :headers => {:content_type => "application/xml"})
    end
    it "should request the correct resource" do
      @t.reply("25938088801", "Testing")
      a_get("/1/statuses/show/25938088801.json").
        with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
        should have_been_made
      a_post("/1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "25938088801", :status => "@sferik Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        should have_been_made
      a_request(:get, "http://checkip.dyndns.org/").
        should have_been_made
      a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        should have_been_made
    end
    it "should have the correct output" do
      @t.reply("25938088801", "Testing")
      $stdout.string.should =~ /^Reply created by @testcli to @sferik \(about 1 year ago\)\.$/
    end
  end

  describe "#report_spam" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/report_spam.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.report_spam("sferik")
      a_post("/1/report_spam.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.report_spam("sferik")
      $stdout.string.should =~ /^@testcli reported @sferik/
    end
  end

  describe "#retweet" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/statuses/retweet/26755176471724032.json").
        to_return(:body => fixture("retweet.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.retweet("26755176471724032")
      a_post("/1/statuses/retweet/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.retweet("26755176471724032")
      $stdout.string.should =~ /^@testcli retweeted @gruber's status: "As for the Series, I'm for the Giants\. Fuck Texas, fuck Nolan Ryan, fuck George Bush\."$/
    end
  end

  describe "#retweets" do
    context "without arguments" do
      before do
        stub_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.retweets
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.retweets
        $stdout.string.should == <<-eos.gsub(/^/, ' ' * 4)
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
    context "with a screen name passed" do
      before do
        stub_get("/1/statuses/retweeted_by_user.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.retweets("sferik")
        a_get("/1/statuses/retweeted_by_user.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.retweets("sferik")
        $stdout.string.should == <<-eos.gsub(/^/, ' ' * 4)
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

  describe "#status" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc", :location => true)
      stub_post("/1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_request(:get, "http://checkip.dyndns.org/").
        to_return(:body => fixture("checkip.html"), :headers => {:content_type => "text/html"})
      stub_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        to_return(:body => fixture("xml.gp"), :headers => {:content_type => "application/xml"})
    end
    it "should request the correct resource" do
      @t.status("Testing")
      a_post("/1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        should have_been_made
      a_request(:get, "http://checkip.dyndns.org/").
        should have_been_made
      a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        should have_been_made
    end
    it "should have the correct output" do
      @t.status("Testing")
      $stdout.string.should =~ /^Tweet created by @testcli \(about 1 year ago\)\.$/
    end
  end

  describe "#suggest" do
    before do
      stub_get("/1/users/recommendations.json").
        with(:query => {:limit => "20", :include_entities => "false"}).
        to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.suggest
      a_get("/1/users/recommendations.json").
        with(:query => {:limit => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.suggest
      $stdout.string.chomp.rstrip.should == "antpires     jtrupiano    maccman      mlroach      stuntmann82"
    end
  end

  describe "#timeline" do
    context "without user" do
      before do
        stub_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.timeline
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.timeline
        $stdout.string.should == <<-eos.gsub(/^/, ' ' * 4)
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
    context "with user" do
      before do
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.timeline("sferik")
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.timeline("sferik")
        $stdout.string.should == <<-eos.gsub(/^/, ' ' * 4)
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

  describe "#unfollow" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      it "should exit" do
        lambda do
          @t.unfollow
        end.should raise_error
      end
    end
    context "one user" do
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.unfollow("sferik")
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.unfollow("sferik")
        $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            to_return(:status => 502)
          lambda do
            @t.unfollow("sferik")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#users" do
    before do
      stub_get("/1/users/lookup.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.users("sferik")
      a_get("/1/users/lookup.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.users("sferik")
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
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
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.whois("sferik")
      a_get("/1/users/show.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.whois("sferik")
      $stdout.string.should == <<-eos.gsub(/^ {8}/, '')
        id: #7,505,382
        Erik Michaels-Ober, since Jul 2007.
        bio: A mind forever voyaging through strange seas of thought, alone.
        location: San Francisco
        web: https://github.com/sferik
      eos
    end
  end

end
