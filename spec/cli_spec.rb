# encoding: utf-8
require 'helper'

describe T::CLI do

  before do
    rcfile = RCFile.instance
    rcfile.path = fixture_path + "/.trc"
    @cli = T::CLI.new
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
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
    end
    it "should have the correct output" do
      @cli.accounts
      $stdout.string.should == <<-eos
testcli
  abc123 (default)
      eos
    end
  end

  describe "#authorize" do
    before do
      @cli.options = @cli.options.merge(:profile => File.expand_path('/tmp/trc', __FILE__), :consumer_key => "abc123", :consumer_secret => "asdfasd223sd2", :prompt => true, :dry_run => true)
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
      @cli.authorize
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
        @cli.authorize
      end.should_not raise_error
    end
  end

  describe "#block" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.block("sferik")
      a_post("/1/blocks/create.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.block("sferik")
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
      @cli.direct_messages
      a_get("/1/direct_messages.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.direct_messages
      $stdout.string.should == <<-eos
              sferik: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
              sferik: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you? (about 1 year ago)
              sferik: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better. (about 1 year ago)
              sferik: Just checking in. How's everything going? (about 1 year ago)
              sferik: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
              sferik: How are the graph enhancements coming? (about 1 year ago)
              sferik: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
              sferik: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
              sferik: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
              sferik: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
      eos
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.direct_messages
        $stdout.string.should == <<-eos
ID          Created at    Screen name  Text
1773478249  Oct 17  2010  sferik       Sounds good. Meeting Tuesday is fine.
1762960771  Oct 14  2010  sferik       That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?
1711812216  Oct  1  2010  sferik       I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.
1711417617  Oct  1  2010  sferik       Just checking in. How's everything going?
1653301471  Sep 16  2010  sferik       Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend?
1645324992  Sep 14  2010  sferik       How are the graph enhancements coming?
1632933616  Sep 11  2010  sferik       How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël.
1629239903  Sep 10  2010  sferik       Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?
1629166212  Sep 10  2010  sferik       I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts.
1624782206  Sep  9  2010  sferik       I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running?
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/direct_messages.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.direct_messages
        a_get("/1/direct_messages.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.direct_messages
        $stdout.string.should == <<-eos
              sferik: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
              sferik: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
              sferik: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
              sferik: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
              sferik: How are the graph enhancements coming? (about 1 year ago)
              sferik: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
              sferik: Just checking in. How's everything going? (about 1 year ago)
              sferik: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better. (about 1 year ago)
              sferik: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you? (about 1 year ago)
              sferik: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
        eos
      end
    end
  end

  describe "#direct_messages_sent" do
    before do
      stub_get("/1/direct_messages/sent.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.direct_messages_sent
      a_get("/1/direct_messages/sent.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.direct_messages_sent
      $stdout.string.should == <<-eos
           hurrycane: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
           hurrycane: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you? (about 1 year ago)
           hurrycane: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better. (about 1 year ago)
           hurrycane: Just checking in. How's everything going? (about 1 year ago)
           hurrycane: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
           hurrycane: How are the graph enhancements coming? (about 1 year ago)
           hurrycane: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
           hurrycane: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
           hurrycane: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
           hurrycane: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
      eos
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.direct_messages_sent
        $stdout.string.should == <<-eos
ID          Created at    Screen name  Text
1773478249  Oct 17  2010  hurrycane    Sounds good. Meeting Tuesday is fine.
1762960771  Oct 14  2010  hurrycane    That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?
1711812216  Oct  1  2010  hurrycane    I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.
1711417617  Oct  1  2010  hurrycane    Just checking in. How's everything going?
1653301471  Sep 16  2010  hurrycane    Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend?
1645324992  Sep 14  2010  hurrycane    How are the graph enhancements coming?
1632933616  Sep 11  2010  hurrycane    How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël.
1629239903  Sep 10  2010  hurrycane    Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?
1629166212  Sep 10  2010  hurrycane    I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts.
1624782206  Sep  9  2010  hurrycane    I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running?
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/direct_messages/sent.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.direct_messages_sent
        a_get("/1/direct_messages/sent.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.direct_messages_sent
        $stdout.string.should == <<-eos
           hurrycane: I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running? (about 1 year ago)
           hurrycane: I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts. (about 1 year ago)
           hurrycane: Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final? (about 1 year ago)
           hurrycane: How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël. (about 1 year ago)
           hurrycane: How are the graph enhancements coming? (about 1 year ago)
           hurrycane: Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend? (about 1 year ago)
           hurrycane: Just checking in. How's everything going? (about 1 year ago)
           hurrycane: I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better. (about 1 year ago)
           hurrycane: That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you? (about 1 year ago)
           hurrycane: Sounds good. Meeting Tuesday is fine. (about 1 year ago)
        eos
      end
    end
  end

  describe "#dm" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem", :include_entities => "false"}).
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.dm("pengwynn", "Creating a fixture for the Twitter gem")
      a_post("/1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.dm("pengwynn", "Creating a fixture for the Twitter gem")
      $stdout.string.chomp.should == "Direct Message sent from @testcli to @pengwynn (about 1 year ago)."
    end
  end

  describe "#favorite" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/favorites/create/26755176471724032.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.favorite("26755176471724032")
      a_post("/1/favorites/create/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.favorite("26755176471724032")
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
      @cli.favorites
      a_get("/1/favorites.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.favorites
      $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
      eos
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.favorites
        $stdout.string.should == <<-eos
ID                  Created at    Screen name   Text
194548121416630272  Apr 23  2011  natevillegas  RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present.
194547993607806976  Apr 23  2011  TD            @kelseysilver how long will you be in town?
194547987593183233  Apr 23  2011  rusashka      @maciej hahaha :) @gpena together we're going to cover all core 28 languages!
194547824690597888  Apr 23  2011  fat           @stevej @xc i'm going to picket when i get back.
194547658562605057  Apr 23  2011  wil           @0x9900 @paulnivin http://t.co/bwVdtAPe
194547528430137344  Apr 23  2011  wangtian      @tianhonghe @xiangxin72 oh, you can even order specific items?
194547402550689793  Apr 23  2011  shinypb       @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird
194547260233760768  Apr 23  2011  0x9900        @wil @paulnivin if you want to take you seriously don't say daemontools!
194547084349804544  Apr 23  2011  kpk           @shinypb @skilldrick @hoverbird invented it
194546876782092291  Apr 23  2011  skilldrick    @shinypb Well played :) @hoverbird
194546811480969217  Apr 23  2011  sam           Can someone project the date that I'll get a 27" retina display?
194546738810458112  Apr 23  2011  shinypb       @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain.
194546727670390784  Apr 23  2011  bartt         @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194546649203347456  Apr 23  2011  skilldrick    @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all.
194546583608639488  Apr 23  2011  sean          @mep Thanks for coming by. Was great to have you.
194546388707717120  Apr 23  2011  hoverbird     @shinypb @trammell it's all suck a "duck blur" sometimes.
194546264212385793  Apr 23  2011  kelseysilver  San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/favorites.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.favorites
        a_get("/1/favorites.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.favorites
        $stdout.string.should == <<-eos
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
        eos
      end
    end
  end

  describe "#follow" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      it "should exit" do
        lambda do
          @cli.follow
        end.should raise_error
      end
    end
    context "one user" do
      it "should request the correct resource" do
        stub_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.follow("sferik")
        a_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_post("/1/friendships/create.json").
          with(:body => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.follow("sferik")
        $stdout.string.should =~ /^@testcli is now following 1 more user\.$/
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_post("/1/friendships/create.json").
            with(:body => {:screen_name => "sferik", :include_entities => "false"}).
            to_return(:status => 502)
          lambda do
            @cli.follow("sferik")
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
      @cli.followings
      a_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.followings
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
14100886  Mar  8  2008  3913    1871       2767       32         185     pengwynn     Wynn Netherland
7505382   Jul 16  2007  2962    88         898        727        29      sferik       Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.followings
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
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
      @cli.followers
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.followers
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
14100886  Mar  8  2008  3913    1871       2767       32         185     pengwynn     Wynn Netherland
7505382   Jul 16  2007  2962    88         898        727        29      sferik       Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.followers
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
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
      @cli.friends
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
      @cli.friends
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
14100886  Mar  8  2008  3913    1871       2767       32         185     pengwynn     Wynn Netherland
7505382   Jul 16  2007  2962    88         898        727        29      sferik       Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.friends
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
  end

  describe "#leaders" do
    before do
      stub_get("/1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/users/lookup.json").
        with(:query => {:user_id => "7505382", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.leaders
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
      @cli.leaders
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
14100886  Mar  8  2008  3913    1871       2767       32         185     pengwynn     Wynn Netherland
7505382   Jul 16  2007  2962    88         898        727        29      sferik       Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.leaders
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1/statuses/mentions.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.mentions
      a_get("/1/statuses/mentions.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.mentions
      $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
      eos
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.mentions
        $stdout.string.should == <<-eos
ID                  Created at    Screen name   Text
194548121416630272  Apr 23  2011  natevillegas  RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present.
194547993607806976  Apr 23  2011  TD            @kelseysilver how long will you be in town?
194547987593183233  Apr 23  2011  rusashka      @maciej hahaha :) @gpena together we're going to cover all core 28 languages!
194547824690597888  Apr 23  2011  fat           @stevej @xc i'm going to picket when i get back.
194547658562605057  Apr 23  2011  wil           @0x9900 @paulnivin http://t.co/bwVdtAPe
194547528430137344  Apr 23  2011  wangtian      @tianhonghe @xiangxin72 oh, you can even order specific items?
194547402550689793  Apr 23  2011  shinypb       @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird
194547260233760768  Apr 23  2011  0x9900        @wil @paulnivin if you want to take you seriously don't say daemontools!
194547084349804544  Apr 23  2011  kpk           @shinypb @skilldrick @hoverbird invented it
194546876782092291  Apr 23  2011  skilldrick    @shinypb Well played :) @hoverbird
194546811480969217  Apr 23  2011  sam           Can someone project the date that I'll get a 27" retina display?
194546738810458112  Apr 23  2011  shinypb       @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain.
194546727670390784  Apr 23  2011  bartt         @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194546649203347456  Apr 23  2011  skilldrick    @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all.
194546583608639488  Apr 23  2011  sean          @mep Thanks for coming by. Was great to have you.
194546388707717120  Apr 23  2011  hoverbird     @shinypb @trammell it's all suck a "duck blur" sometimes.
194546264212385793  Apr 23  2011  kelseysilver  San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/statuses/mentions.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.mentions
        a_get("/1/statuses/mentions.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.mentions
        $stdout.string.should == <<-eos
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
        eos
      end
    end
  end

  describe "#open" do
    before do
      @cli.options = @cli.options.merge(:dry_run => true)
    end
    it "should not raise error" do
      lambda do
        @cli.open("sferik")
      end.should_not raise_error
    end
  end

  describe "#reply" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc", :location => true)
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
      @cli.reply("25938088801", "Testing")
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
      @cli.reply("25938088801", "Testing")
      $stdout.string.should =~ /^Reply created by @testcli to @sferik \(about 1 year ago\)\.$/
    end
  end

  describe "#report_spam" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/report_spam.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.report_spam("sferik")
      a_post("/1/report_spam.json").
        with(:body => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.report_spam("sferik")
      $stdout.string.should =~ /^@testcli reported @sferik/
    end
  end

  describe "#retweet" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
      stub_post("/1/statuses/retweet/26755176471724032.json").
        to_return(:body => fixture("retweet.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.retweet("26755176471724032")
      a_post("/1/statuses/retweet/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.retweet("26755176471724032")
      $stdout.string.should =~ /^@testcli retweeted @gruber's status: "As for the Series, I'm for the Giants\. Fuck Texas, fuck Nolan Ryan, fuck George Bush\."$/
    end
  end

  describe "#retweets" do
    before do
      stub_get("/1/statuses/retweeted_by_me.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "without arguments" do
      it "should request the correct resource" do
        @cli.retweets
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.retweets
        $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.retweets
        $stdout.string.should == <<-eos
ID                  Created at    Screen name   Text
194548121416630272  Apr 23  2011  natevillegas  RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present.
194547993607806976  Apr 23  2011  TD            @kelseysilver how long will you be in town?
194547987593183233  Apr 23  2011  rusashka      @maciej hahaha :) @gpena together we're going to cover all core 28 languages!
194547824690597888  Apr 23  2011  fat           @stevej @xc i'm going to picket when i get back.
194547658562605057  Apr 23  2011  wil           @0x9900 @paulnivin http://t.co/bwVdtAPe
194547528430137344  Apr 23  2011  wangtian      @tianhonghe @xiangxin72 oh, you can even order specific items?
194547402550689793  Apr 23  2011  shinypb       @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird
194547260233760768  Apr 23  2011  0x9900        @wil @paulnivin if you want to take you seriously don't say daemontools!
194547084349804544  Apr 23  2011  kpk           @shinypb @skilldrick @hoverbird invented it
194546876782092291  Apr 23  2011  skilldrick    @shinypb Well played :) @hoverbird
194546811480969217  Apr 23  2011  sam           Can someone project the date that I'll get a 27" retina display?
194546738810458112  Apr 23  2011  shinypb       @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain.
194546727670390784  Apr 23  2011  bartt         @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194546649203347456  Apr 23  2011  skilldrick    @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all.
194546583608639488  Apr 23  2011  sean          @mep Thanks for coming by. Was great to have you.
194546388707717120  Apr 23  2011  hoverbird     @shinypb @trammell it's all suck a "duck blur" sometimes.
194546264212385793  Apr 23  2011  kelseysilver  San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.retweets
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.retweets
        $stdout.string.should == <<-eos
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
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
        @cli.retweets("sferik")
        a_get("/1/statuses/retweeted_by_user.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.retweets("sferik")
        $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
        eos
      end
    end
  end

  describe "#suggest" do
    before do
      stub_get("/1/users/recommendations.json").
        with(:query => {:limit => "20", :include_entities => "false"}).
        to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.suggest
      a_get("/1/users/recommendations.json").
        with(:query => {:limit => "20", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.suggest
      $stdout.string.chomp.rstrip.should == "antpires     jtrupiano    maccman      mlroach      stuntmann82"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "maccman      mlroach      jtrupiano    stuntmann82  antpires"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  antpires     maccman      mlroach      jtrupiano"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
40514587  May 16  2009  183     198        158        2          2       antpires     AntonioPires
14736332  May 11  2008  3850    545        802        117        99      jtrupiano    John Trupiano
2006261   Mar 23  2007  4497    967        2028       9          171     maccman      Alex MacCaw
14451152  Apr 20  2008  6251    403        299        10         20      mlroach      Matt Laroche
16052754  Aug 30  2008  24      5          42         0          1       stuntmann82  stuntmann82
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/users/recommendations.json").
          with(:query => {:limit => "1", :include_entities => "false"}).
          to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.suggest
        a_get("/1/users/recommendations.json").
          with(:query => {:limit => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  mlroach      maccman      jtrupiano    antpires"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.suggest
        $stdout.string.chomp.rstrip.should == "stuntmann82  antpires     jtrupiano    maccman      mlroach"
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1/statuses/home_timeline.json").
        with(:query => {:count => "20", :include_entities => "false"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "without user" do
      it "should request the correct resource" do
        @cli.timeline
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "20", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.timeline
        $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.timeline
        $stdout.string.should == <<-eos
ID                  Created at    Screen name   Text
194548121416630272  Apr 23  2011  natevillegas  RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present.
194547993607806976  Apr 23  2011  TD            @kelseysilver how long will you be in town?
194547987593183233  Apr 23  2011  rusashka      @maciej hahaha :) @gpena together we're going to cover all core 28 languages!
194547824690597888  Apr 23  2011  fat           @stevej @xc i'm going to picket when i get back.
194547658562605057  Apr 23  2011  wil           @0x9900 @paulnivin http://t.co/bwVdtAPe
194547528430137344  Apr 23  2011  wangtian      @tianhonghe @xiangxin72 oh, you can even order specific items?
194547402550689793  Apr 23  2011  shinypb       @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird
194547260233760768  Apr 23  2011  0x9900        @wil @paulnivin if you want to take you seriously don't say daemontools!
194547084349804544  Apr 23  2011  kpk           @shinypb @skilldrick @hoverbird invented it
194546876782092291  Apr 23  2011  skilldrick    @shinypb Well played :) @hoverbird
194546811480969217  Apr 23  2011  sam           Can someone project the date that I'll get a 27" retina display?
194546738810458112  Apr 23  2011  shinypb       @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain.
194546727670390784  Apr 23  2011  bartt         @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194546649203347456  Apr 23  2011  skilldrick    @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all.
194546583608639488  Apr 23  2011  sean          @mep Thanks for coming by. Was great to have you.
194546388707717120  Apr 23  2011  hoverbird     @shinypb @trammell it's all suck a "duck blur" sometimes.
194546264212385793  Apr 23  2011  kelseysilver  San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge(:number => 1)
        stub_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.timeline
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "1", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.timeline
        $stdout.string.should == <<-eos
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
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
        @cli.timeline("sferik")
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "20", :include_entities => "false", :screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.timeline("sferik")
        $stdout.string.should == <<-eos
        natevillegas: RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present. (7 months ago)
                  TD: @kelseysilver how long will you be in town? (7 months ago)
            rusashka: @maciej hahaha :) @gpena together we're going to cover all core 28 languages! (7 months ago)
                 fat: @stevej @xc i'm going to picket when i get back. (7 months ago)
                 wil: @0x9900 @paulnivin http://t.co/bwVdtAPe (7 months ago)
            wangtian: @tianhonghe @xiangxin72 oh, you can even order specific items? (7 months ago)
             shinypb: @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird (7 months ago)
              0x9900: @wil @paulnivin if you want to take you seriously don't say daemontools! (7 months ago)
                 kpk: @shinypb @skilldrick @hoverbird invented it (7 months ago)
          skilldrick: @shinypb Well played :) @hoverbird (7 months ago)
                 sam: Can someone project the date that I'll get a 27" retina display? (7 months ago)
             shinypb: @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
          skilldrick: @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all. (7 months ago)
                sean: @mep Thanks for coming by. Was great to have you. (7 months ago)
           hoverbird: @shinypb @trammell it's all suck a "duck blur" sometimes. (7 months ago)
        kelseysilver: San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw (7 months ago)
        eos
      end
    end
  end

  describe "#unfollow" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      it "should exit" do
        lambda do
          @cli.unfollow
        end.should raise_error
      end
    end
    context "one user" do
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.unfollow("sferik")
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.unfollow("sferik")
        $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            to_return(:status => 502)
          lambda do
            @cli.unfollow("sferik")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#update" do
    before do
      @cli.options = @cli.options.merge(:profile => fixture_path + "/.trc", :location => true)
      stub_post("/1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_request(:get, "http://checkip.dyndns.org/").
        to_return(:body => fixture("checkip.html"), :headers => {:content_type => "text/html"})
      stub_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        to_return(:body => fixture("xml.gp"), :headers => {:content_type => "application/xml"})
    end
    it "should request the correct resource" do
      @cli.update("Testing")
      a_post("/1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :include_entities => "false", :trim_user => "true"}).
        should have_been_made
      a_request(:get, "http://checkip.dyndns.org/").
        should have_been_made
      a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.update("Testing")
      $stdout.string.should =~ /^Tweet created by @testcli \(about 1 year ago\)\.$/
    end
  end

  describe "#users" do
    before do
      stub_get("/1/users/lookup.json").
        with(:query => {:screen_name => "sferik,pengwynn", :include_entities => "false"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.users("sferik", "pengwynn")
      a_get("/1/users/lookup.json").
        with(:query => {:screen_name => "sferik,pengwynn", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.users("sferik", "pengwynn")
      $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
    end
    context "--created" do
      before do
        @cli.options = @cli.options.merge(:created => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--favorites" do
      before do
        @cli.options = @cli.options.merge(:favorites => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "pengwynn  sferik"
      end
    end
    context "--followers" do
      before do
        @cli.options = @cli.options.merge(:followers => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--friends" do
      before do
        @cli.options = @cli.options.merge(:friends => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--listed" do
      before do
        @cli.options = @cli.options.merge(:listed => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge(:long => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.should == <<-eos
ID        Created at    Tweets  Following  Followers  Favorites  Listed  Screen name  Name
14100886  Mar  8  2008  3913    1871       2767       32         185     pengwynn     Wynn Netherland
7505382   Jul 16  2007  2962    88         898        727        29      sferik       Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
    context "--tweets" do
      before do
        @cli.options = @cli.options.merge(:tweets => true)
      end
      it "should list in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.rstrip.should == "sferik    pengwynn"
      end
    end
  end

  describe "#version" do
    it "should have the correct output" do
      @cli.version
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
      @cli.whois("sferik")
      a_get("/1/users/show.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.whois("sferik")
      $stdout.string.should == <<-eos
id: #7,505,382
Erik Michaels-Ober, since Jul 2007.
bio: A mind forever voyaging through strange seas of thought, alone.
location: San Francisco
web: https://github.com/sferik
      eos
    end
  end

end
