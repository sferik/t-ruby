# encoding: utf-8
require 'helper'

describe T::CLI do

  before :all do
    Timecop.freeze(Time.utc(2011, 11, 24, 16, 20, 0))
    T.utc_offset = 'PST'
  end

  after :all do
    T.utc_offset = nil
    Timecop.return
  end

  before :each do
    T::RCFile.instance.path = fixture_path + "/.trc"
    @cli = T::CLI.new
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after :each do
    T::RCFile.instance.reset
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#account" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
    end
    it "should have the correct output" do
      @cli.accounts
      $stdout.string.should == <<-eos
testcli
  abc123 (active)
      eos
    end
  end

  describe "#authorize" do
    before do
      @cli.options = @cli.options.merge("profile" => project_path + "/tmp/authorize", "display-url" => true)
      stub_post("/oauth/request_token").
        to_return(:body => fixture("request_token"))
      stub_post("/oauth/access_token").
        to_return(:body => fixture("access_token"))
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      $stdout.should_receive(:print)
      $stdin.should_receive(:gets).and_return("\n")
      $stdout.should_receive(:print).with("Enter your consumer key: ")
      $stdin.should_receive(:gets).and_return("abc123")
      $stdout.should_receive(:print).with("Enter your consumer secret: ")
      $stdin.should_receive(:gets).and_return("asdfasd223sd2")
      $stdout.should_receive(:print).with("Press [Enter] to open the Twitter app authorization page. ")
      $stdin.should_receive(:gets).and_return("\n")
      $stdout.should_receive(:print).with("Enter the supplied PIN: ")
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
        $stdout.should_receive(:print)
        $stdin.should_receive(:gets).and_return("\n")
        $stdout.should_receive(:print).with("Enter your consumer key: ")
        $stdin.should_receive(:gets).and_return("abc123")
        $stdout.should_receive(:print).with("Enter your consumer secret: ")
        $stdin.should_receive(:gets).and_return("asdfasd223sd2")
        $stdout.should_receive(:print).with("Press [Enter] to open the Twitter app authorization page. ")
        $stdin.should_receive(:gets).and_return("\n")
        $stdout.should_receive(:print).with("Enter the supplied PIN: ")
        $stdin.should_receive(:gets).and_return("1234567890")
        @cli.authorize
      end.should_not raise_error
    end
  end

  describe "#block" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_post("/1.1/blocks/create.json").
        with(:body => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.block("sferik")
      a_post("/1.1/blocks/create.json").
        with(:body => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.block("sferik")
      $stdout.string.should =~ /^@testcli blocked 1 user/
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_post("/1.1/blocks/create.json").
          with(:body => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.block("7505382")
        a_post("/1.1/blocks/create.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
    end
  end

  describe "#direct_messages" do
    before do
      stub_get("/1.1/direct_messages.json").
        with(:query => {:count => "20"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/direct_messages.json").
        with(:query => {:count => "10", "max_id"=>"1624782205"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.direct_messages
      a_get("/1.1/direct_messages.json").
        with(:query => {:count => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.direct_messages
      $stdout.string.should == <<-eos
\e[1m\e[33m   @sferik\e[0m
   Sounds good. Meeting Tuesday is fine.

\e[1m\e[33m   @sferik\e[0m
   That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does 
   that work for you?

\e[1m\e[33m   @sferik\e[0m
   I asked Yehuda about the stipend. I believe it has already been sent. Glad 
   you're feeling better.

\e[1m\e[33m   @sferik\e[0m
   Just checking in. How's everything going?

\e[1m\e[33m   @sferik\e[0m
   Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think 
   you'll be able to finish up your work on graphs this weekend?

\e[1m\e[33m   @sferik\e[0m
   How are the graph enhancements coming?

\e[1m\e[33m   @sferik\e[0m
   How are the graphs coming? I'm really looking forward to seeing what you do 
   with Raphaël.

\e[1m\e[33m   @sferik\e[0m
   Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?

\e[1m\e[33m   @sferik\e[0m
   I just committed a bunch of cleanup and fixes to RailsAdmin that touched many 
   of files. Make sure you pull to avoid conflicts.

\e[1m\e[33m   @sferik\e[0m
   I'm trying to debug the issue you were having with the Bundler Gemfile.lock 
   shortref. What version of Ruby and RubyGems are you running?

      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.direct_messages
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
1773478249,2010-10-17 20:48:55 +0000,sferik,Sounds good. Meeting Tuesday is fine.
1762960771,2010-10-14 21:43:30 +0000,sferik,That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?
1711812216,2010-10-01 15:07:12 +0000,sferik,I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.
1711417617,2010-10-01 13:09:27 +0000,sferik,Just checking in. How's everything going?
1653301471,2010-09-16 16:13:27 +0000,sferik,Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend?
1645324992,2010-09-14 18:44:10 +0000,sferik,How are the graph enhancements coming?
1632933616,2010-09-11 17:45:46 +0000,sferik,How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël.
1629239903,2010-09-10 18:21:36 +0000,sferik,Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?
1629166212,2010-09-10 17:56:53 +0000,sferik,I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts.
1624782206,2010-09-09 18:11:48 +0000,sferik,I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running?
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.direct_messages
        $stdout.string.should == <<-eos
ID          Posted at     Screen name  Text
1773478249  Oct 17  2010  @sferik      Sounds good. Meeting Tuesday is fine.
1762960771  Oct 14  2010  @sferik      That's great news! Let's plan to chat ...
1711812216  Oct  1  2010  @sferik      I asked Yehuda about the stipend. I be...
1711417617  Oct  1  2010  @sferik      Just checking in. How's everything going?
1653301471  Sep 16  2010  @sferik      Not sure about the payment. Feel free ...
1645324992  Sep 14  2010  @sferik      How are the graph enhancements coming?
1632933616  Sep 11  2010  @sferik      How are the graphs coming? I'm really ...
1629239903  Sep 10  2010  @sferik      Awesome! Any luck duplicating the Gemf...
1629166212  Sep 10  2010  @sferik      I just committed a bunch of cleanup an...
1624782206  Sep  9  2010  @sferik      I'm trying to debug the issue you were...
        eos
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/direct_messages.json").
          with(:query => {:count => "1"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/direct_messages.json").
          with(:query => {:count => "200"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/direct_messages.json").
          with(:query => {:count => "200", :max_id => "1624782205"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (5..195).step(10).to_a.reverse.each do |count|
          stub_get("/1.1/direct_messages.json").
            with(:query => {:count => count, :max_id => "1624782205"}).
            to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results to 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.direct_messages
        a_get("/1.1/direct_messages.json").
          with(:query => {:count => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.direct_messages
        a_get("/1.1/direct_messages.json").
          with(:query => {:count => "200"}).
          should have_been_made
        a_get("/1.1/direct_messages.json").
          with(:query => {:count => "200", :max_id => "1624782205"}).
          should have_been_made.times(14)
        (5..195).step(10).to_a.reverse.each do |count|
          a_get("/1.1/direct_messages.json").
            with(:query => {:count => count, :max_id => "1624782205"}).
            should have_been_made
        end
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.direct_messages
        $stdout.string.should == <<-eos
\e[1m\e[33m   @sferik\e[0m
   I'm trying to debug the issue you were having with the Bundler Gemfile.lock 
   shortref. What version of Ruby and RubyGems are you running?

\e[1m\e[33m   @sferik\e[0m
   I just committed a bunch of cleanup and fixes to RailsAdmin that touched many 
   of files. Make sure you pull to avoid conflicts.

\e[1m\e[33m   @sferik\e[0m
   Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?

\e[1m\e[33m   @sferik\e[0m
   How are the graphs coming? I'm really looking forward to seeing what you do 
   with Raphaël.

\e[1m\e[33m   @sferik\e[0m
   How are the graph enhancements coming?

\e[1m\e[33m   @sferik\e[0m
   Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think 
   you'll be able to finish up your work on graphs this weekend?

\e[1m\e[33m   @sferik\e[0m
   Just checking in. How's everything going?

\e[1m\e[33m   @sferik\e[0m
   I asked Yehuda about the stipend. I believe it has already been sent. Glad 
   you're feeling better.

\e[1m\e[33m   @sferik\e[0m
   That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does 
   that work for you?

\e[1m\e[33m   @sferik\e[0m
   Sounds good. Meeting Tuesday is fine.

        eos
      end
    end
  end

  describe "#direct_messages_sent" do
    before do
      stub_get("/1.1/direct_messages/sent.json").
        with(:query => {:count => "20"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/direct_messages/sent.json").
        with(:query => {:count => "10", "max_id"=>"1624782205"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.direct_messages_sent
      a_get("/1.1/direct_messages/sent.json").
        with(:query => {:count => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.direct_messages_sent
      $stdout.string.should == <<-eos
\e[1m\e[33m   @hurrycane\e[0m
   Sounds good. Meeting Tuesday is fine.

\e[1m\e[33m   @hurrycane\e[0m
   That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does 
   that work for you?

\e[1m\e[33m   @hurrycane\e[0m
   I asked Yehuda about the stipend. I believe it has already been sent. Glad 
   you're feeling better.

\e[1m\e[33m   @hurrycane\e[0m
   Just checking in. How's everything going?

\e[1m\e[33m   @hurrycane\e[0m
   Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think 
   you'll be able to finish up your work on graphs this weekend?

\e[1m\e[33m   @hurrycane\e[0m
   How are the graph enhancements coming?

\e[1m\e[33m   @hurrycane\e[0m
   How are the graphs coming? I'm really looking forward to seeing what you do 
   with Raphaël.

\e[1m\e[33m   @hurrycane\e[0m
   Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?

\e[1m\e[33m   @hurrycane\e[0m
   I just committed a bunch of cleanup and fixes to RailsAdmin that touched many 
   of files. Make sure you pull to avoid conflicts.

\e[1m\e[33m   @hurrycane\e[0m
   I'm trying to debug the issue you were having with the Bundler Gemfile.lock 
   shortref. What version of Ruby and RubyGems are you running?

      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.direct_messages_sent
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
1773478249,2010-10-17 20:48:55 +0000,hurrycane,Sounds good. Meeting Tuesday is fine.
1762960771,2010-10-14 21:43:30 +0000,hurrycane,That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does that work for you?
1711812216,2010-10-01 15:07:12 +0000,hurrycane,I asked Yehuda about the stipend. I believe it has already been sent. Glad you're feeling better.
1711417617,2010-10-01 13:09:27 +0000,hurrycane,Just checking in. How's everything going?
1653301471,2010-09-16 16:13:27 +0000,hurrycane,Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think you'll be able to finish up your work on graphs this weekend?
1645324992,2010-09-14 18:44:10 +0000,hurrycane,How are the graph enhancements coming?
1632933616,2010-09-11 17:45:46 +0000,hurrycane,How are the graphs coming? I'm really looking forward to seeing what you do with Raphaël.
1629239903,2010-09-10 18:21:36 +0000,hurrycane,Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?
1629166212,2010-09-10 17:56:53 +0000,hurrycane,I just committed a bunch of cleanup and fixes to RailsAdmin that touched many of files. Make sure you pull to avoid conflicts.
1624782206,2010-09-09 18:11:48 +0000,hurrycane,I'm trying to debug the issue you were having with the Bundler Gemfile.lock shortref. What version of Ruby and RubyGems are you running?
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.direct_messages_sent
        $stdout.string.should == <<-eos
ID          Posted at     Screen name  Text
1773478249  Oct 17  2010  @hurrycane   Sounds good. Meeting Tuesday is fine.
1762960771  Oct 14  2010  @hurrycane   That's great news! Let's plan to chat ...
1711812216  Oct  1  2010  @hurrycane   I asked Yehuda about the stipend. I be...
1711417617  Oct  1  2010  @hurrycane   Just checking in. How's everything going?
1653301471  Sep 16  2010  @hurrycane   Not sure about the payment. Feel free ...
1645324992  Sep 14  2010  @hurrycane   How are the graph enhancements coming?
1632933616  Sep 11  2010  @hurrycane   How are the graphs coming? I'm really ...
1629239903  Sep 10  2010  @hurrycane   Awesome! Any luck duplicating the Gemf...
1629166212  Sep 10  2010  @hurrycane   I just committed a bunch of cleanup an...
1624782206  Sep  9  2010  @hurrycane   I'm trying to debug the issue you were...
        eos
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "1"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "200"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "200", :max_id => "1624782205"}).
          to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (5..195).step(10).to_a.reverse.each do |count|
          stub_get("/1.1/direct_messages/sent.json").
            with(:query => {:count => count, :max_id => "1624782205"}).
            to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.direct_messages_sent
        a_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.direct_messages_sent
        a_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "200"}).
          should have_been_made
        a_get("/1.1/direct_messages/sent.json").
          with(:query => {:count => "200", :max_id => "1624782205"}).
          should have_been_made.times(14)
        (5..195).step(10).to_a.reverse.each do |count|
          a_get("/1.1/direct_messages/sent.json").
            with(:query => {:count => count, :max_id => "1624782205"}).
            should have_been_made
        end
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.direct_messages_sent
        $stdout.string.should == <<-eos
\e[1m\e[33m   @hurrycane\e[0m
   I'm trying to debug the issue you were having with the Bundler Gemfile.lock 
   shortref. What version of Ruby and RubyGems are you running?

\e[1m\e[33m   @hurrycane\e[0m
   I just committed a bunch of cleanup and fixes to RailsAdmin that touched many 
   of files. Make sure you pull to avoid conflicts.

\e[1m\e[33m   @hurrycane\e[0m
   Awesome! Any luck duplicating the Gemfile.lock error with Ruby 1.9.2 final?

\e[1m\e[33m   @hurrycane\e[0m
   How are the graphs coming? I'm really looking forward to seeing what you do 
   with Raphaël.

\e[1m\e[33m   @hurrycane\e[0m
   How are the graph enhancements coming?

\e[1m\e[33m   @hurrycane\e[0m
   Not sure about the payment. Feel free to ask Leah or Yehuda directly. Think 
   you'll be able to finish up your work on graphs this weekend?

\e[1m\e[33m   @hurrycane\e[0m
   Just checking in. How's everything going?

\e[1m\e[33m   @hurrycane\e[0m
   I asked Yehuda about the stipend. I believe it has already been sent. Glad 
   you're feeling better.

\e[1m\e[33m   @hurrycane\e[0m
   That's great news! Let's plan to chat around 8 AM tomorrow Pacific time. Does 
   that work for you?

\e[1m\e[33m   @hurrycane\e[0m
   Sounds good. Meeting Tuesday is fine.

        eos
      end
    end
  end

  describe "#groupies" do
    before do
      stub_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "213747670,428004849"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.groupies
      a_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "213747670,428004849"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.groupies
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.groupies
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.groupies
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.groupies
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.groupies
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.groupies
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.groupies
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.groupies
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.groupies
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.groupies
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.groupies
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.groupies
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.groupies("sferik")
        a_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "213747670,428004849"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.groupies("7505382")
          a_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "213747670,428004849"}).
            should have_been_made
        end
      end
    end
  end

  describe "#dm" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_post("/1.1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.dm("pengwynn", "Creating a fixture for the Twitter gem")
      a_post("/1.1/direct_messages/new.json").
        with(:body => {:screen_name => "pengwynn", :text => "Creating a fixture for the Twitter gem"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.dm("pengwynn", "Creating a fixture for the Twitter gem")
      $stdout.string.chomp.should == "Direct Message sent from @testcli to @pengwynn."
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_post("/1.1/direct_messages/new.json").
          with(:body => {:user_id => "14100886", :text => "Creating a fixture for the Twitter gem"}).
          to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.dm("14100886", "Creating a fixture for the Twitter gem")
        a_post("/1.1/direct_messages/new.json").
          with(:body => {:user_id => "14100886", :text => "Creating a fixture for the Twitter gem"}).
          should have_been_made
      end
    end
  end

  describe "#does_contain" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_get("/1.1/lists/members/show.json").
        with(:query => {:owner_screen_name => "testcli", :screen_name => "testcli", :slug => "presidents"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.does_contain("presidents")
      a_get("/1.1/lists/members/show.json").
        with(:query => {:owner_screen_name => "testcli", :screen_name => "testcli", :slug => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.does_contain("presidents")
      $stdout.string.chomp.should == "Yes, presidents contains @testcli."
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/users/show.json").
          with(:query => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/lists/members/show.json").
          with(:query => {:owner_screen_name => "testcli", :screen_name => "sferik", :slug => "presidents"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.does_contain("presidents", "7505382")
        a_get("/1.1/users/show.json").
          with(:query => {:user_id => "7505382"}).
          should have_been_made
        a_get("/1.1/lists/members/show.json").
          with(:query => {:owner_screen_name => "testcli", :screen_name => "sferik", :slug => "presidents"}).
          should have_been_made
      end
    end
    context "with an owner passed" do
      it "should have the correct output" do
        @cli.does_contain("testcli/presidents", "testcli")
        $stdout.string.chomp.should == "Yes, presidents contains @testcli."
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/users/show.json").
            with(:query => {:user_id => "7505382"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/lists/members/show.json").
            with(:query => {:owner_id => "7505382", :screen_name => "sferik", :slug => "presidents"}).
            to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.does_contain("7505382/presidents", "7505382")
          a_get("/1.1/users/show.json").
            with(:query => {:user_id => "7505382"}).
            should have_been_made
          a_get("/1.1/lists/members/show.json").
            with(:query => {:owner_id => "7505382", :screen_name => "sferik", :slug => "presidents"}).
            should have_been_made
        end
      end
    end
    context "with a user passed" do
      it "should have the correct output" do
        @cli.does_contain("presidents", "testcli")
        $stdout.string.chomp.should == "Yes, presidents contains @testcli."
      end
    end
    context "false" do
      before do
        stub_get("/1.1/lists/members/show.json").
          with(:query => {:owner_screen_name => "testcli", :screen_name => "testcli", :slug => "presidents"}).
          to_return(:body => fixture("not_found.json"), :status => 404, :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should exit" do
        lambda do
          @cli.does_contain("presidents")
        end.should raise_error(SystemExit)
        a_get("/1.1/lists/members/show.json").
          with(:query => {:owner_screen_name => "testcli", :screen_name => "testcli", :slug => "presidents"}).
          should have_been_made
      end
    end
  end

  describe "#does_follow" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_get("/1.1/friendships/show.json").
        with(:query => {:source_screen_name => "ev", :target_screen_name => "testcli"}).
        to_return(:body => fixture("following.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.does_follow("ev")
      a_get("/1.1/friendships/show.json").
        with(:query => {:source_screen_name => "ev", :target_screen_name => "testcli"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.does_follow("ev")
      $stdout.string.chomp.should == "Yes, @ev follows @testcli."
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/users/show.json").
          with(:query => {:user_id => "20"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/friendships/show.json").
          with(:query => {:source_screen_name => "sferik", :target_screen_name => "testcli"}).
          to_return(:body => fixture("following.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.does_follow("20")
        a_get("/1.1/users/show.json").
          with(:query => {:user_id => "20"}).
          should have_been_made
        a_get("/1.1/friendships/show.json").
          with(:query => {:source_screen_name => "sferik", :target_screen_name => "testcli"}).
          should have_been_made
      end
    end
    context "with a user passed" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/users/show.json").
          with(:query => {:user_id => "0"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/friendships/show.json").
          with(:query => {:source_screen_name => "sferik", :target_screen_name => "sferik"}).
          to_return(:body => fixture("following.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.does_follow("ev", "testcli")
        $stdout.string.chomp.should == "Yes, @sferik follows @sferik."
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/users/show.json").
            with(:query => {:user_id => "20"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/users/show.json").
            with(:query => {:user_id => "428004849"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.does_follow("20", "428004849")
          a_get("/1.1/users/show.json").
            with(:query => {:user_id => "20"}).
            should have_been_made
          a_get("/1.1/users/show.json").
            with(:query => {:user_id => "428004849"}).
            should have_been_made
          a_get("/1.1/friendships/show.json").
            with(:query => {:source_screen_name => "sferik", :target_screen_name => "sferik"}).
            should have_been_made
        end
      end
    end
    context "false" do
      before do
        stub_get("/1.1/friendships/show.json").
          with(:query => {:source_screen_name => "ev", :target_screen_name => "testcli"}).
          to_return(:body => fixture("not_following.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should exit" do
        lambda do
          @cli.does_follow("ev")
        end.should raise_error(SystemExit)
        a_get("/1.1/friendships/show.json").
          with(:query => {:source_screen_name => "ev", :target_screen_name => "testcli"}).
          should have_been_made
      end
    end
  end

  describe "#favorite" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_post("/1.1/favorites/create.json").
        with(:body => {:id => "26755176471724032"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.favorite("26755176471724032")
      a_post("/1.1/favorites/create.json").
        with(:body => {:id => "26755176471724032"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.favorite("26755176471724032")
      $stdout.string.should =~ /^@testcli favorited 1 tweet.$/
    end
  end

  describe "#favorites" do
    before do
      stub_get("/1.1/favorites/list.json").
        with(:query => {:count => "20"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.favorites
      a_get("/1.1/favorites/list.json").
        with(:query => {:count => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.favorites
      $stdout.string.should == <<-eos
\e[1m\e[33m   @mutgoff\e[0m
   Happy Birthday @imdane. Watch out for those @rally pranksters!

\e[1m\e[33m   @ironicsans\e[0m
   If you like good real-life stories, check out @NarrativelyNY's just-launched 
   site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)

\e[1m\e[33m   @pat_shaughnessy\e[0m
   Something else to vote for: "New Rails workshops to bring more women into the 
   Boston software scene" http://t.co/eNBuckHc /cc @bostonrb

\e[1m\e[33m   @calebelston\e[0m
   Pushing the button to launch the site. http://t.co/qLoEn5jG

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @fivethirtyeight\e[0m
   The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, 
   THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @mbostock\e[0m
   If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u

\e[1m\e[33m   @FakeDorsey\e[0m
   “Write drunk. Edit sober.”—Ernest Hemingway

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @calebelston\e[0m
   We just announced Mosaic, what we've been working on since the Yobongo 
   acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic

\e[1m\e[33m   @BarackObama\e[0m
   Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 
   #Obama2012

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @eveningedition\e[0m
   LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake 
   China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @jasonfried\e[0m
   The story of Mars Curiosity's gears, made by a factory in Rockford, IL: 
   http://t.co/MwCRsHQg

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

\e[1m\e[33m   @dwiskus\e[0m
   Gentlemen, you can't fight in here! This is the war room! 
   http://t.co/kMxMYyqF

      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.favorites
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
244111636544225280,2012-09-07 16:35:24 +0000,mutgoff,Happy Birthday @imdane. Watch out for those @rally pranksters!
244111183165157376,2012-09-07 16:33:36 +0000,ironicsans,"If you like good real-life stories, check out @NarrativelyNY's just-launched site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)"
244110336414859264,2012-09-07 16:30:14 +0000,pat_shaughnessy,"Something else to vote for: ""New Rails workshops to bring more women into the Boston software scene"" http://t.co/eNBuckHc /cc @bostonrb"
244109797308379136,2012-09-07 16:28:05 +0000,calebelston,Pushing the button to launch the site. http://t.co/qLoEn5jG
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107890632294400,2012-09-07 16:20:31 +0000,fivethirtyeight,"The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)"
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244106476048764928,2012-09-07 16:14:53 +0000,mbostock,If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u
244105599351148544,2012-09-07 16:11:24 +0000,FakeDorsey,“Write drunk. Edit sober.”—Ernest Hemingway
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244104146997870594,2012-09-07 16:05:38 +0000,calebelston,"We just announced Mosaic, what we've been working on since the Yobongo acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic"
244103057175113729,2012-09-07 16:01:18 +0000,BarackObama,Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 #Obama2012
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102741125890048,2012-09-07 16:00:03 +0000,eveningedition,LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244102490646278146,2012-09-07 15:59:03 +0000,jasonfried,"The story of Mars Curiosity's gears, made by a factory in Rockford, IL: http://t.co/MwCRsHQg"
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
244099460672679938,2012-09-07 15:47:01 +0000,dwiskus,"Gentlemen, you can't fight in here! This is the war room! http://t.co/kMxMYyqF"
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.favorites
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
        eos
      end
      context "--reverse" do
        before do
          @cli.options = @cli.options.merge("reverse" => true)
        end
        it "should reverse the order of the sort" do
          @cli.favorites
          $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
          eos
        end
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/favorites/list.json").
          with(:query => {:count => "1"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/favorites/list.json").
          with(:query => {:count => "200"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/favorites/list.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (5..185).step(20).to_a.reverse.each do |count|
          stub_get("/1.1/favorites/list.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results to 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.favorites
        a_get("/1.1/favorites/list.json").
          with(:query => {:count => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.favorites
        a_get("/1.1/favorites/list.json").
          with(:query => {:count => "200"}).
          should have_been_made
        a_get("/1.1/favorites/list.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          should have_been_made.times(7)
        (5..185).step(20).to_a.reverse.each do |count|
          a_get("/1.1/favorites/list.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            should have_been_made
        end
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/favorites/list.json").
          with(:query => {:count => "20", :screen_name => "sferik"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.favorites("sferik")
        a_get("/1.1/favorites/list.json").
          with(:query => {:count => "20", :screen_name => "sferik"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/favorites/list.json").
            with(:query => {:user_id => "7505382", :count => "20"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.favorites("7505382")
          a_get("/1.1/favorites/list.json").
            with(:query => {:user_id => "7505382", :count => "20"}).
            should have_been_made
        end
      end
    end
  end

  describe "#follow" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
    end
    context "one user" do
      before do
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1.1/users/lookup.json").
          with(:body => {:screen_name => "sferik,pengwynn"}).
          to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1.1/friendships/create.json").
          with(:body => {:user_id => "14100886"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.follow("sferik", "pengwynn")
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:screen_name => "sferik,pengwynn"}).
          should have_been_made
        a_post("/1.1/friendships/create.json").
          with(:body => {:user_id => "14100886"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.follow("sferik", "pengwynn")
        $stdout.string.should =~ /^@testcli is now following 1 more user\.$/
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "7505382,14100886"}).
            to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_post("/1.1/friendships/create.json").
            with(:body => {:user_id => "14100886"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.follow("7505382", "14100886")
          a_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1"}).
            should have_been_made
          a_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "7505382,14100886"}).
            should have_been_made
          a_post("/1.1/friendships/create.json").
            with(:body => {:user_id => "14100886"}).
            should have_been_made
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_post("/1.1/users/lookup.json").
            with(:body => {:screen_name => "sferik,pengwynn"}).
            to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_post("/1.1/friendships/create.json").
            with(:body => {:user_id => "14100886"}).
            to_return(:status => 502)
          lambda do
            @cli.follow("sferik", "pengwynn")
          end.should raise_error("Twitter is down or being upgraded.")
          a_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1"}).
            should have_been_made.times(3)
          a_post("/1.1/users/lookup.json").
            with(:body => {:screen_name => "sferik,pengwynn"}).
            should have_been_made.times(3)
          a_post("/1.1/friendships/create.json").
            with(:body => {:user_id => "14100886"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#followings" do
    before do
      stub_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.followings
      a_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.followings
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.followings
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.followings
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.followings
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.followings
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.followings
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.followings
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.followings
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.followings
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.followings
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.followings
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.followings
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.followings("sferik")
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :user_id => "7505382"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.followings("7505382")
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :user_id => "7505382"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
    end
  end

  describe "#followers" do
    before do
      stub_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.followers
      a_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.followers
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.followers
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.followers
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.followers
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.followers
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.followers
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.followers
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.followers
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.followers
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.followers
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.followers
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.followers
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "213747670,428004849"}).
          to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.followers("sferik")
        a_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.followers("7505382")
          a_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "7505382"}).
            should have_been_made
        end
      end
    end
  end

  describe "#friends" do
    before do
      stub_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.friends
      a_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.friends
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.friends
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.friends
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.friends
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.friends
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.friends
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.friends
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.friends
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.friends
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.friends
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.friends
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.friends
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.friends("sferik")
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.friends("7505382")
          a_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "7505382"}).
            should have_been_made
        end
      end
    end
  end

  describe "#leaders" do
    before do
      stub_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.leaders
      a_get("/1.1/friends/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_get("/1.1/followers/ids.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
      a_post("/1.1/users/lookup.json").
        with(:body => {:user_id => "7505382"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.leaders
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.leaders
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.leaders
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
         eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.leaders
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.leaders
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.leaders
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.leaders
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.leaders
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.leaders
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.leaders
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.leaders
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.leaders
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.leaders("sferik")
        a_get("/1.1/friends/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_get("/1.1/followers/ids.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.leaders("7505382")
          a_get("/1.1/friends/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_get("/1.1/followers/ids.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
          a_post("/1.1/users/lookup.json").
            with(:body => {:user_id => "7505382"}).
            should have_been_made
        end
      end
    end
  end

  describe "#lists" do
    before do
      stub_get("/1.1/lists/list.json").
        with(:query => {:cursor => "-1"}).
        to_return(:body => fixture("lists.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.lists
      a_get("/1.1/lists/list.json").
        with(:query => {:cursor => "-1"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.lists
      $stdout.string.chomp.should == "@sferik/code-for-america  @sferik/presidents"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.lists
        $stdout.string.should == <<-eos
ID,Created at,Screen name,Slug,Members,Subscribers,Mode,Description
21718825,2010-09-14 21:46:56 +0000,sferik,code-for-america,26,5,public,Code for America
8863586,2010-03-15 12:10:13 +0000,sferik,presidents,2,1,public,Presidents of the United States of America
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.lists
        $stdout.string.should == <<-eos
ID        Created at    Screen name  Slug              Members  Subscribers  ...
21718825  Sep 14  2010  @sferik      code-for-america       26            5  ...
 8863586  Mar 15  2010  @sferik      presidents              2            1  ...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/presidents        @sferik/code-for-america"
      end
    end
    context "--sort=members" do
      before do
        @cli.options = @cli.options.merge("sort" => "members")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/presidents        @sferik/code-for-america"
      end
    end
    context "--sort=mode" do
      before do
        @cli.options = @cli.options.merge("sort" => "mode")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/code-for-america  @sferik/presidents"
      end
    end
    context "--sort=posted" do
      before do
        @cli.options = @cli.options.merge("sort" => "posted")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/presidents        @sferik/code-for-america"
      end
    end
    context "--sort=subscribers" do
      before do
        @cli.options = @cli.options.merge("sort" => "subscribers")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/presidents        @sferik/code-for-america"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.lists
        $stdout.string.chomp.should == "@sferik/code-for-america  @sferik/presidents"
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/lists/list.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          to_return(:body => fixture("lists.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.lists("sferik")
        a_get("/1.1/lists/list.json").
          with(:query => {:cursor => "-1", :screen_name => "sferik"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/lists/list.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            to_return(:body => fixture("lists.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.lists("7505382")
          a_get("/1.1/lists/list.json").
            with(:query => {:cursor => "-1", :user_id => "7505382"}).
            should have_been_made
        end
      end
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1.1/statuses/mentions_timeline.json").
        with(:query => {:count => "20"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.mentions
      a_get("/1.1/statuses/mentions_timeline.json").
        with(:query => {:count => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.mentions
      $stdout.string.should == <<-eos
\e[1m\e[33m   @mutgoff\e[0m
   Happy Birthday @imdane. Watch out for those @rally pranksters!

\e[1m\e[33m   @ironicsans\e[0m
   If you like good real-life stories, check out @NarrativelyNY's just-launched 
   site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)

\e[1m\e[33m   @pat_shaughnessy\e[0m
   Something else to vote for: "New Rails workshops to bring more women into the 
   Boston software scene" http://t.co/eNBuckHc /cc @bostonrb

\e[1m\e[33m   @calebelston\e[0m
   Pushing the button to launch the site. http://t.co/qLoEn5jG

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @fivethirtyeight\e[0m
   The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, 
   THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @mbostock\e[0m
   If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u

\e[1m\e[33m   @FakeDorsey\e[0m
   “Write drunk. Edit sober.”—Ernest Hemingway

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @calebelston\e[0m
   We just announced Mosaic, what we've been working on since the Yobongo 
   acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic

\e[1m\e[33m   @BarackObama\e[0m
   Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 
   #Obama2012

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @eveningedition\e[0m
   LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake 
   China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @jasonfried\e[0m
   The story of Mars Curiosity's gears, made by a factory in Rockford, IL: 
   http://t.co/MwCRsHQg

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

\e[1m\e[33m   @dwiskus\e[0m
   Gentlemen, you can't fight in here! This is the war room! 
   http://t.co/kMxMYyqF

      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.mentions
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
244111636544225280,2012-09-07 16:35:24 +0000,mutgoff,Happy Birthday @imdane. Watch out for those @rally pranksters!
244111183165157376,2012-09-07 16:33:36 +0000,ironicsans,"If you like good real-life stories, check out @NarrativelyNY's just-launched site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)"
244110336414859264,2012-09-07 16:30:14 +0000,pat_shaughnessy,"Something else to vote for: ""New Rails workshops to bring more women into the Boston software scene"" http://t.co/eNBuckHc /cc @bostonrb"
244109797308379136,2012-09-07 16:28:05 +0000,calebelston,Pushing the button to launch the site. http://t.co/qLoEn5jG
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107890632294400,2012-09-07 16:20:31 +0000,fivethirtyeight,"The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)"
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244106476048764928,2012-09-07 16:14:53 +0000,mbostock,If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u
244105599351148544,2012-09-07 16:11:24 +0000,FakeDorsey,“Write drunk. Edit sober.”—Ernest Hemingway
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244104146997870594,2012-09-07 16:05:38 +0000,calebelston,"We just announced Mosaic, what we've been working on since the Yobongo acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic"
244103057175113729,2012-09-07 16:01:18 +0000,BarackObama,Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 #Obama2012
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102741125890048,2012-09-07 16:00:03 +0000,eveningedition,LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244102490646278146,2012-09-07 15:59:03 +0000,jasonfried,"The story of Mars Curiosity's gears, made by a factory in Rockford, IL: http://t.co/MwCRsHQg"
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
244099460672679938,2012-09-07 15:47:01 +0000,dwiskus,"Gentlemen, you can't fight in here! This is the war room! http://t.co/kMxMYyqF"
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.mentions
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
        eos
      end
      context "--reverse" do
        before do
          @cli.options = @cli.options.merge("reverse" => true)
        end
        it "should reverse the order of the sort" do
          @cli.mentions
          $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
          eos
        end
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "1"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "200"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (5..185).step(20).to_a.reverse.each do |count|
          stub_get("/1.1/statuses/mentions_timeline.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results to 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.mentions
        a_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.mentions
        a_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "200"}).
          should have_been_made
        a_get("/1.1/statuses/mentions_timeline.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          should have_been_made.times(7)
        (5..185).step(20).to_a.reverse.each do |count|
          a_get("/1.1/statuses/mentions_timeline.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            should have_been_made
        end
      end
    end
  end

  describe "#open" do
    before do
      @cli.options = @cli.options.merge("display-url" => true)
    end
    it "should have the correct output" do
      lambda do
        @cli.open("sferik")
      end.should_not raise_error
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/users/show.json").
          with(:query => {:user_id => "420"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.open("420")
        a_get("/1.1/users/show.json").
          with(:query => {:user_id => "420"}).
          should have_been_made
      end
    end
    context "--status" do
      before do
        @cli.options = @cli.options.merge("status" => true)
        stub_get("/1.1/statuses/show/55709764298092545.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.open("55709764298092545")
        a_get("/1.1/statuses/show/55709764298092545.json").
          with(:query => {:include_my_retweet => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        lambda do
          @cli.open("55709764298092545")
        end.should_not raise_error
      end
    end
  end

  describe "#rate_limit" do
    before do
      stub_get("/1.1/application/rate_limit_status.json").
        to_return(:body => fixture("rate_limit_status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.rate_limit
      a_get("/1.1/application/rate_limit_status.json").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.rate_limit
      $stdout.string.should == <<-eos
Hourly limit    20,000
Remaining hits  19,993
Reset time      Oct 26  2010 (a year from now)
      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should have the correct output" do
        @cli.rate_limit
        $stdout.string.should == <<-eos
Hourly limit,Remaining hits,Reset time
20000,19993,2010-10-26 12:43:08 +0000
        eos
      end
    end
  end

  describe "#reply" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc", "location" => true)
      stub_get("/1.1/statuses/show/55709764298092545.json").
        with(:query => {:include_my_retweet => "false"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1.1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "55709764298092545", :status => "@sferik Testing", :lat => "37.76969909668", :long => "-122.39330291748", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_request(:get, "http://checkip.dyndns.org/").
        to_return(:body => fixture("checkip.html"), :headers => {:content_type => "text/html"})
      stub_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        to_return(:body => fixture("geoplugin.xml"), :headers => {:content_type => "application/xml"})
    end
    it "should request the correct resource" do
      @cli.reply("55709764298092545", "Testing")
      a_get("/1.1/statuses/show/55709764298092545.json").
        with(:query => {:include_my_retweet => "false"}).
        should have_been_made
      a_post("/1.1/statuses/update.json").
        with(:body => {:in_reply_to_status_id => "55709764298092545", :status => "@sferik Testing", :lat => "37.76969909668", :long => "-122.39330291748", :trim_user => "true"}).
        should have_been_made
      a_request(:get, "http://checkip.dyndns.org/").
        should have_been_made
      a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.reply("55709764298092545", "Testing")
      $stdout.string.split("\n").first.should == "Reply posted by @testcli to @sferik."
    end
    context "--all" do
      before do
        @cli.options = @cli.options.merge("all" => true)
      end
      it "should request the correct resource" do
        @cli.reply("55709764298092545", "Testing")
        a_get("/1.1/statuses/show/55709764298092545.json").
          with(:query => {:include_my_retweet => "false"}).
          should have_been_made
        a_post("/1.1/statuses/update.json").
          with(:body => {:in_reply_to_status_id => "55709764298092545", :status => "@sferik Testing", :lat => "37.76969909668", :long => "-122.39330291748", :trim_user => "true"}).
          should have_been_made
        a_request(:get, "http://checkip.dyndns.org/").
          should have_been_made
        a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
          should have_been_made
      end
      it "should have the correct output" do
        @cli.reply("55709764298092545", "Testing")
        $stdout.string.split("\n").first.should == "Reply posted by @testcli to @sferik."
      end
    end
  end

  describe "#report_spam" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_post("/1.1/report_spam.json").
        with(:body => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.report_spam("sferik")
      a_post("/1.1/report_spam.json").
        with(:body => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.report_spam("sferik")
      $stdout.string.should =~ /^@testcli reported 1 user/
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_post("/1.1/report_spam.json").
          with(:body => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.report_spam("7505382")
        a_post("/1.1/report_spam.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
    end
  end

  describe "#retweet" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
      stub_post("/1.1/statuses/retweet/26755176471724032.json").
        to_return(:body => fixture("retweet.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.retweet("26755176471724032")
      a_post("/1.1/statuses/retweet/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.retweet("26755176471724032")
      $stdout.string.should =~ /^@testcli retweeted 1 tweet.$/
    end
  end

  describe "#retweets" do
    before do
      stub_get("/1.1/statuses/user_timeline.json").
        with(:query => {:count => "200", :include_rts => "true"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/statuses/user_timeline.json").
        with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "without arguments" do
      it "should request the correct resource" do
        @cli.retweets
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true"}).
          should have_been_made
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"}).
          should have_been_made.times(3)
      end
      it "should have the correct output" do
        @cli.retweets
        $stdout.string.should == <<-eos
\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

        eos
      end
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.retweets
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
       eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.retweets
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name      Text
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
        eos
      end
      context "--reverse" do
        before do
          @cli.options = @cli.options.merge("reverse" => true)
        end
        it "should reverse the order of the sort" do
          @cli.retweets
          $stdout.string.should == <<-eos
ID                  Posted at     Screen name      Text
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
244102729860009984  Sep  7 08:00  @dhh             RT @ggreenwald: Democrats ...
244102834398851073  Sep  7 08:00  @JEG2            RT @tenderlove: If corpora...
244104558433951744  Sep  7 08:07  @al3x            RT @wcmaier: Better bankin...
244107236262170624  Sep  7 08:17  @fbjork          RT @jondot: Just published...
244107823733174272  Sep  7 08:20  @codeforamerica  RT @randomhacks: Going to ...
244108728834592770  Sep  7 08:23  @calebelston     RT @olivercameron: Mosaic ...
          eos
        end
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :max_id => "244107823733174271"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results to 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.retweets
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.retweets
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true"}).
          should have_been_made
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :max_id => "244107823733174271"}).
          should have_been_made
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.retweets("sferik")
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"}).
          should have_been_made
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"}).
          should have_been_made.times(3)
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.retweets("7505382")
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"}).
            should have_been_made
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#ruler" do
    it "should have the correct output" do
      @cli.ruler
      $stdout.string.chomp.size.should == 140
      $stdout.string.chomp.should == "----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|"
    end
    context "with indentation" do
      before do
        @cli.options = @cli.options.merge("indent" => 2)
      end
      it "should have the correct output" do
        @cli.ruler
        $stdout.string.chomp.size.should == 142
        $stdout.string.chomp.should == "  ----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|"
      end
    end
  end

  describe "#status" do
    before do
      stub_get("/1.1/statuses/show/55709764298092545.json").
        with(:query => {:include_my_retweet => "false"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.status("55709764298092545")
      a_get("/1.1/statuses/show/55709764298092545.json").
        with(:query => {:include_my_retweet => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.status("55709764298092545")
      $stdout.string.should == <<-eos
ID           55709764298092545
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For, 2170 Bryant St, San Francisco, California, United States
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092545
      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should have the correct output" do
        @cli.status("55709764298092545")
        $stdout.string.should == <<-eos
ID,Text,Screen name,Posted at,Location,Retweets,Source,URL
55709764298092545,The problem with your code is that it's doing exactly what you told it to do.,sferik,2011-04-06 19:13:37 +0000,"Blowfish Sushi To Die For, 2170 Bryant St, San Francisco, California, United States",320,Twitter for iPhone,https://twitter.com/sferik/status/55709764298092545
        eos
      end
    end
    context "with no street address" do
      before do
        stub_get("/1.1/statuses/show/55709764298092550.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status_no_street_address.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.status("55709764298092550")
        $stdout.string.should == <<-eos
ID           55709764298092550
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For, San Francisco, California, United States
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092550
        eos
      end
    end
    context "with no locality" do
      before do
        stub_get("/1.1/statuses/show/55709764298092549.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status_no_locality.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.status("55709764298092549")
        $stdout.string.should == <<-eos
ID           55709764298092549
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For, San Francisco, California, United States
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092549
        eos
      end
    end
    context "with no attributes" do
      before do
        stub_get("/1.1/statuses/show/55709764298092546.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status_no_attributes.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.status("55709764298092546")
        $stdout.string.should == <<-eos
ID           55709764298092546
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For, San Francisco, United States
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092546
        eos
      end
    end
    context "with no country" do
      before do
        stub_get("/1.1/statuses/show/55709764298092547.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status_no_country.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.status("55709764298092547")
        $stdout.string.should == <<-eos
ID           55709764298092547
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For, San Francisco
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092547
        eos
      end
    end
    context "with no full name" do
      before do
        stub_get("/1.1/statuses/show/55709764298092548.json").
          with(:query => {:include_my_retweet => "false"}).
          to_return(:body => fixture("status_no_full_name.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should have the correct output" do
        @cli.status("55709764298092548")
        $stdout.string.should == <<-eos
ID           55709764298092548
Text         The problem with your code is that it's doing exactly what you told it to do.
Screen name  @sferik
Posted at    Apr  6  2011 (8 months ago)
Location     Blowfish Sushi To Die For
Retweets     320
Source       Twitter for iPhone
URL          https://twitter.com/sferik/status/55709764298092548
        eos
      end
    end
  end

  describe "#suggest" do
    before do
      stub_get("/1.1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/users/recommendations.json").
        with(:query => {:limit => "20", :screen_name => "sferik"}).
        to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.suggest
      stub_get("/1.1/account/verify_credentials.json").
        should have_been_made
      a_get("/1.1/users/recommendations.json").
        with(:query => {:limit => "20", :screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.suggest
      $stdout.string.chomp.should == "antpires     jtrupiano    maccman      mlroach      stuntmann82"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.suggest
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
40514587,2009-05-16 18:24:33 +0000,2011-06-13 16:27:31 +0000,183,2,2,198,158,antpires,AntonioPires
14736332,2008-05-11 19:46:06 +0000,2011-08-20 03:27:22 +0000,3850,117,99,545,802,jtrupiano,John Trupiano
2006261,2007-03-23 12:36:14 +0000,2011-08-21 23:54:01 +0000,4497,9,171,967,2028,maccman,Alex MacCaw
14451152,2008-04-20 12:05:38 +0000,2011-08-21 20:59:41 +0000,6251,10,20,403,299,mlroach,Matt Laroche
16052754,2008-08-30 08:22:57 +0000,2009-11-25 06:20:05 +0000,24,0,1,5,42,stuntmann82,stuntmann82
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.suggest
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
40514587  May 16  2009  Jun 13 08:27        183          2       2        198...
14736332  May 11  2008  Aug 19 19:27       3850        117      99        545...
 2006261  Mar 23  2007  Aug 21 15:54       4497          9     171        967...
14451152  Apr 20  2008  Aug 21 12:59       6251         10      20        403...
16052754  Aug 30  2008  Nov 24  2009         24          0       1          5...
        eos
      end
    end
    context "--number" do
      before do
        @cli.options = @cli.options.merge("number" => 1)
        stub_get("/1.1/users/recommendations.json").
          with(:query => {:limit => "1", :screen_name => "sferik"}).
          to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @cli.suggest
        a_get("/1.1/users/recommendations.json").
          with(:query => {:limit => "1", :screen_name => "sferik"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  mlroach      maccman      jtrupiano    antpires"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     maccman      mlroach      jtrupiano"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     mlroach      jtrupiano    maccman"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.suggest
        $stdout.string.chomp.should == "maccman      mlroach      jtrupiano    stuntmann82  antpires"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     jtrupiano    maccman      mlroach"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.suggest
        $stdout.string.chomp.should == "stuntmann82  antpires     jtrupiano    mlroach      maccman"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.suggest
        $stdout.string.chomp.should == "jtrupiano    mlroach      antpires     maccman      stuntmann82"
      end
    end
    context "with a user passed" do
      it "should request the correct resource" do
        @cli.suggest("sferik")
        a_get("/1.1/users/recommendations.json").
          with(:query => {:limit => "20", :screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.suggest("sferik")
        $stdout.string.chomp.should == "antpires     jtrupiano    maccman      mlroach      stuntmann82"
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/users/recommendations.json").
            with(:query => {:limit => "20", :user_id => "7505382"}).
            to_return(:body => fixture("recommendations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.suggest("7505382")
          a_get("/1.1/users/recommendations.json").
            with(:query => {:limit => "20", :user_id => "7505382"}).
            should have_been_made
        end
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1.1/statuses/home_timeline.json").
        with(:query => {:count => "20"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "without user" do
      it "should request the correct resource" do
        @cli.timeline
        a_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "20"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.timeline
        $stdout.string.should == <<-eos
\e[1m\e[33m   @mutgoff\e[0m
   Happy Birthday @imdane. Watch out for those @rally pranksters!

\e[1m\e[33m   @ironicsans\e[0m
   If you like good real-life stories, check out @NarrativelyNY's just-launched 
   site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)

\e[1m\e[33m   @pat_shaughnessy\e[0m
   Something else to vote for: "New Rails workshops to bring more women into the 
   Boston software scene" http://t.co/eNBuckHc /cc @bostonrb

\e[1m\e[33m   @calebelston\e[0m
   Pushing the button to launch the site. http://t.co/qLoEn5jG

\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

\e[1m\e[33m   @fivethirtyeight\e[0m
   The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, 
   THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)

\e[1m\e[33m   @codeforamerica\e[0m
   RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, 
   Sep 8 http://t.co/Sk5BM7U3 We'll see y'all there! #rhok @codeforamerica 
   @TheaClay

\e[1m\e[33m   @fbjork\e[0m
   RT @jondot: Just published: "Pragmatic Concurrency With #Ruby" 
   http://t.co/kGEykswZ /cc @JRuby @headius

\e[1m\e[33m   @mbostock\e[0m
   If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u

\e[1m\e[33m   @FakeDorsey\e[0m
   “Write drunk. Edit sober.”—Ernest Hemingway

\e[1m\e[33m   @al3x\e[0m
   RT @wcmaier: Better banking through better ops: build something new with us 
   @Simplify (remote, PDX) http://t.co/8WgzKZH3

\e[1m\e[33m   @calebelston\e[0m
   We just announced Mosaic, what we've been working on since the Yobongo 
   acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic

\e[1m\e[33m   @BarackObama\e[0m
   Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 
   #Obama2012

\e[1m\e[33m   @JEG2\e[0m
   RT @tenderlove: If corporations are people, can we use them to drive in the 
   carpool lane?

\e[1m\e[33m   @eveningedition\e[0m
   LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake 
   China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4

\e[1m\e[33m   @dhh\e[0m
   RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest 
   achievement: why this goulish jingoism is so warped http://t.co/kood278s

\e[1m\e[33m   @jasonfried\e[0m
   The story of Mars Curiosity's gears, made by a factory in Rockford, IL: 
   http://t.co/MwCRsHQg

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

\e[1m\e[33m   @dwiskus\e[0m
   Gentlemen, you can't fight in here! This is the war room! 
   http://t.co/kMxMYyqF

        eos
      end
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.timeline
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
244111636544225280,2012-09-07 16:35:24 +0000,mutgoff,Happy Birthday @imdane. Watch out for those @rally pranksters!
244111183165157376,2012-09-07 16:33:36 +0000,ironicsans,"If you like good real-life stories, check out @NarrativelyNY's just-launched site http://t.co/wiUL07jE (and also visit http://t.co/ZoyQxqWA)"
244110336414859264,2012-09-07 16:30:14 +0000,pat_shaughnessy,"Something else to vote for: ""New Rails workshops to bring more women into the Boston software scene"" http://t.co/eNBuckHc /cc @bostonrb"
244109797308379136,2012-09-07 16:28:05 +0000,calebelston,Pushing the button to launch the site. http://t.co/qLoEn5jG
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
244107890632294400,2012-09-07 16:20:31 +0000,fivethirtyeight,"The Weatherman is Not a Moron: http://t.co/ZwL5Gnq5. An excerpt from my book, THE SIGNAL AND THE NOISE (http://t.co/fNXj8vCE)"
244107823733174272,2012-09-07 16:20:15 +0000,codeforamerica,"RT @randomhacks: Going to Code Across Austin II: Y'all Come Hack Now, Sat, Sep 8 http://t.co/Sk5BM7U3  We'll see y'all there! #rhok @codeforamerica @TheaClay"
244107236262170624,2012-09-07 16:17:55 +0000,fbjork,"RT @jondot: Just published: ""Pragmatic Concurrency With #Ruby"" http://t.co/kGEykswZ   /cc @JRuby @headius"
244106476048764928,2012-09-07 16:14:53 +0000,mbostock,If you are wondering how we computed the split bubbles: http://t.co/BcaqSs5u
244105599351148544,2012-09-07 16:11:24 +0000,FakeDorsey,“Write drunk. Edit sober.”—Ernest Hemingway
244104558433951744,2012-09-07 16:07:16 +0000,al3x,"RT @wcmaier: Better banking through better ops: build something new with us @Simplify (remote, PDX) http://t.co/8WgzKZH3"
244104146997870594,2012-09-07 16:05:38 +0000,calebelston,"We just announced Mosaic, what we've been working on since the Yobongo acquisition. My personal post, http://t.co/ELOyIRZU @heymosaic"
244103057175113729,2012-09-07 16:01:18 +0000,BarackObama,Donate $10 or more --> get your favorite car magnet: http://t.co/NfRhl2s2 #Obama2012
244102834398851073,2012-09-07 16:00:25 +0000,JEG2,"RT @tenderlove: If corporations are people, can we use them to drive in the carpool lane?"
244102741125890048,2012-09-07 16:00:03 +0000,eveningedition,LDN—Obama's nomination; Putin woos APEC; Bombs hit Damascus; Quakes shake China; Canada cuts Iran ties; weekend read: http://t.co/OFs6dVW4
244102729860009984,2012-09-07 16:00:00 +0000,dhh,RT @ggreenwald: Democrats parade Osama bin Laden's corpse as their proudest achievement: why this goulish jingoism is so warped http://t.co/kood278s
244102490646278146,2012-09-07 15:59:03 +0000,jasonfried,"The story of Mars Curiosity's gears, made by a factory in Rockford, IL: http://t.co/MwCRsHQg"
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
244099460672679938,2012-09-07 15:47:01 +0000,dwiskus,"Gentlemen, you can't fight in here! This is the war room! http://t.co/kMxMYyqF"
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.timeline
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
        eos
      end
      context "--reverse" do
        before do
          @cli.options = @cli.options.merge("reverse" => true)
        end
        it "should reverse the order of the sort" do
          @cli.timeline
          $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
244099460672679938  Sep  7 07:47  @dwiskus          Gentlemen, you can't figh...
244100411563339777  Sep  7 07:50  @sferik           @episod @twitterapi Did y...
244102209942458368  Sep  7 07:57  @sferik           @episod @twitterapi now h...
244102490646278146  Sep  7 07:59  @jasonfried       The story of Mars Curiosi...
244102729860009984  Sep  7 08:00  @dhh              RT @ggreenwald: Democrats...
244102741125890048  Sep  7 08:00  @eveningedition   LDN—Obama's nomination; P...
244102834398851073  Sep  7 08:00  @JEG2             RT @tenderlove: If corpor...
244103057175113729  Sep  7 08:01  @BarackObama      Donate $10 or more --> ge...
244104146997870594  Sep  7 08:05  @calebelston      We just announced Mosaic,...
244104558433951744  Sep  7 08:07  @al3x             RT @wcmaier: Better banki...
244105599351148544  Sep  7 08:11  @FakeDorsey       “Write drunk. Edit sober....
244106476048764928  Sep  7 08:14  @mbostock         If you are wondering how ...
244107236262170624  Sep  7 08:17  @fbjork           RT @jondot: Just publishe...
244107823733174272  Sep  7 08:20  @codeforamerica   RT @randomhacks: Going to...
244107890632294400  Sep  7 08:20  @fivethirtyeight  The Weatherman is Not a M...
244108728834592770  Sep  7 08:23  @calebelston      RT @olivercameron: Mosaic...
244109797308379136  Sep  7 08:28  @calebelston      Pushing the button to lau...
244110336414859264  Sep  7 08:30  @pat_shaughnessy  Something else to vote fo...
244111183165157376  Sep  7 08:33  @ironicsans       If you like good real-lif...
244111636544225280  Sep  7 08:35  @mutgoff          Happy Birthday @imdane. W...
          eos
        end
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "1"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "200"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (5..185).step(20).to_a.reverse.each do |count|
          stub_get("/1.1/statuses/home_timeline.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results to 1" do
        @cli.options = @cli.options.merge("number" => 1)
        @cli.timeline
        a_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @cli.options = @cli.options.merge("number" => 345)
        @cli.timeline
        a_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "200"}).
          should have_been_made
        a_get("/1.1/statuses/home_timeline.json").
          with(:query => {:count => "200", :max_id => "244099460672679937"}).
          should have_been_made.times(7)
        (5..185).step(20).to_a.reverse.each do |count|
          a_get("/1.1/statuses/home_timeline.json").
            with(:query => {:count => count, :max_id => "244099460672679937"}).
            should have_been_made
        end
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "20", :screen_name => "sferik"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.timeline("sferik")
        a_get("/1.1/statuses/user_timeline.json").
          with(:query => {:count => "20", :screen_name => "sferik"}).
          should have_been_made
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "20", :user_id => "7505382"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.timeline("7505382")
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "20", :user_id => "7505382"}).
            should have_been_made
        end
      end
      context "--number" do
        before do
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "1", :screen_name => "sferik"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :screen_name => "sferik"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244099460672679937"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          (5..185).step(20).to_a.reverse.each do |count|
            stub_get("/1.1/statuses/user_timeline.json").
              with(:query => {:count => count, :screen_name => "sferik", :max_id => "244099460672679937"}).
              to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          end
        end
        it "should limit the number of results to 1" do
          @cli.options = @cli.options.merge("number" => 1)
          @cli.timeline("sferik")
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "1", :screen_name => "sferik"}).
            should have_been_made
        end
        it "should limit the number of results to 345" do
          @cli.options = @cli.options.merge("number" => 345)
          @cli.timeline("sferik")
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :screen_name => "sferik"}).
            should have_been_made
          a_get("/1.1/statuses/user_timeline.json").
            with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244099460672679937"}).
            should have_been_made.times(7)
          (5..185).step(20).to_a.reverse.each do |count|
            a_get("/1.1/statuses/user_timeline.json").
              with(:query => {:count => count, :screen_name => "sferik", :max_id => "244099460672679937"}).
              should have_been_made
          end
        end
      end
    end
  end

  describe "#trends" do
    before do
      stub_get("/1.1/trends/place.json").
        with(:query => {:id => "1"}).
        to_return(:body => fixture("trends.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.trends
      a_get("/1.1/trends/place.json").
        with(:query => {:id => "1"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.trends
      $stdout.string.chomp.should == "#sevenwordsaftersex  Walkman              Allen Iverson"
    end
    context "--exclude-hashtags" do
      before do
        @cli.options = @cli.options.merge("exclude-hashtags" => true)
        stub_get("/1.1/trends/place.json").
          with(:query => {:id => "1", :exclude => "hashtags"}).
          to_return(:body => fixture("trends.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.trends
        a_get("/1.1/trends/place.json").
          with(:query => {:id => "1", :exclude => "hashtags"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.trends
        $stdout.string.chomp.should == "#sevenwordsaftersex  Walkman              Allen Iverson"
      end
    end
    context "with a WOEID passed" do
      before do
        stub_get("/1.1/trends/place.json").
          with(:query => {:id => "2487956"}).
          to_return(:body => fixture("trends.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.trends("2487956")
        a_get("/1.1/trends/place.json").
          with(:query => {:id => "2487956"}).
          should have_been_made
      end
      it "should have the correct output" do
        @cli.trends("2487956")
        $stdout.string.chomp.should == "#sevenwordsaftersex  Walkman              Allen Iverson"
      end
    end
  end

  describe "#trend_locations" do
    before do
      stub_get("/1.1/trends/available.json").
        to_return(:body => fixture("locations.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.trend_locations
      a_get("/1.1/trends/available.json").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.trend_locations
      $stdout.string.chomp.should == "Boston         New York       San Francisco  United States  Worldwide"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.trend_locations
        $stdout.string.chomp.should == <<-eos.chomp
WOEID,Parent ID,Type,Name,Country
2367105,,Town,Boston,United States
2459115,,Town,New York,United States
2487956,,Town,San Francisco,United States
23424977,,Country,United States,United States
1,,Supername,Worldwide,""
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.trend_locations
        $stdout.string.chomp.should == <<-eos.chomp
WOEID     Parent ID  Type       Name           Country
 2367105             Town       Boston         United States
 2459115             Town       New York       United States
 2487956             Town       San Francisco  United States
23424977             Country    United States  United States
       1             Supername  Worldwide      
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.trend_locations
        $stdout.string.chomp.should == "Worldwide      United States  San Francisco  New York       Boston"
      end
    end
    context "--sort=country" do
      before do
        @cli.options = @cli.options.merge("sort" => "country")
      end
      it "should sort by number of favorites" do
        @cli.trend_locations
        $stdout.string.chomp.should == "Worldwide      New York       Boston         United States  San Francisco"
      end
    end
    context "--sort=parent" do
      before do
        @cli.options = @cli.options.merge("sort" => "parent")
      end
      it "should sort by number of favorites" do
        @cli.trend_locations
        $stdout.string.chomp.should == "Boston         Worldwide      New York       United States  San Francisco"
      end
    end
    context "--sort=type" do
      before do
        @cli.options = @cli.options.merge("sort" => "type")
      end
      it "should sort by number of favorites" do
        @cli.trend_locations
        $stdout.string.chomp.should == "United States  Worldwide      New York       Boston         San Francisco"
      end
    end
    context "--sort=woeid" do
      before do
        @cli.options = @cli.options.merge("sort" => "woeid")
      end
      it "should sort by number of favorites" do
        @cli.trend_locations
        $stdout.string.chomp.should == "Worldwide      Boston         New York       San Francisco  United States"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.trend_locations
        $stdout.string.chomp.should == "Boston         Worldwide      New York       United States  San Francisco"
      end
    end
  end

  describe "#unfollow" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc")
    end
    context "one user" do
      it "should request the correct resource" do
        stub_post("/1.1/friendships/destroy.json").
          with(:body => {:screen_name => "sferik"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.unfollow("sferik")
        a_post("/1.1/friendships/destroy.json").
          with(:body => {:screen_name => "sferik"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_post("/1.1/friendships/destroy.json").
          with(:body => {:screen_name => "sferik"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @cli.unfollow("sferik")
        $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
      end
      context "--id" do
        before do
          @cli.options = @cli.options.merge("id" => true)
          stub_post("/1.1/friendships/destroy.json").
            with(:body => {:user_id => "7505382"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @cli.unfollow("7505382")
          a_post("/1.1/friendships/destroy.json").
            with(:body => {:user_id => "7505382"}).
            should have_been_made
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_post("/1.1/friendships/destroy.json").
            with(:body => {:screen_name => "sferik"}).
            to_return(:status => 502)
          lambda do
            @cli.unfollow("sferik")
          end.should raise_error("Twitter is down or being upgraded.")
          a_post("/1.1/friendships/destroy.json").
            with(:body => {:screen_name => "sferik"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#update" do
    before do
      @cli.options = @cli.options.merge("profile" => fixture_path + "/.trc", "location" => true)
      stub_post("/1.1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_request(:get, "http://checkip.dyndns.org/").
        to_return(:body => fixture("checkip.html"), :headers => {:content_type => "text/html"})
      stub_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        to_return(:body => fixture("geoplugin.xml"), :headers => {:content_type => "application/xml"})
    end
    it "should request the correct resource" do
      @cli.update("Testing")
      a_post("/1.1/statuses/update.json").
        with(:body => {:status => "Testing", :lat => "37.76969909668", :long => "-122.39330291748", :trim_user => "true"}).
        should have_been_made
      a_request(:get, "http://checkip.dyndns.org/").
        should have_been_made
      a_request(:get, "http://www.geoplugin.net/xml.gp?ip=50.131.22.169").
        should have_been_made
    end
    it "should have the correct output" do
      @cli.update("Testing")
      $stdout.string.split("\n").first.should == "Tweet posted by @testcli."
    end
    context "with file" do
      before do
        @cli.options = @cli.options.merge("file" => fixture_path + "/long.png")
        stub_post("/1.1/statuses/update_with_media.json").
          to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.update("Testing")
        a_post("/1.1/statuses/update_with_media.json").
          should have_been_made
      end
      it "should have the correct output" do
        @cli.update("Testing")
        $stdout.string.split("\n").first.should == "Tweet posted by @testcli."
      end
    end
  end

  describe "#users" do
    before do
      stub_post("/1.1/users/lookup.json").
        with(:body => {:screen_name => "sferik,pengwynn"}).
        to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.users("sferik", "pengwynn")
      a_post("/1.1/users/lookup.json").
        with(:body => {:screen_name => "sferik,pengwynn"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.users("sferik", "pengwynn")
      $stdout.string.chomp.should == "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.should == <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @cli.options = @cli.options.merge("long" => true)
      end
      it "should output in long format" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.should == <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @cli.options = @cli.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @cli.options = @cli.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @cli.options = @cli.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @cli.options = @cli.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382,14100886"}).
          to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.users("7505382", "14100886")
        a_post("/1.1/users/lookup.json").
          with(:body => {:user_id => "7505382,14100886"}).
          should have_been_made
      end
    end
    context "--sort=listed" do
      before do
        @cli.options = @cli.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @cli.options = @cli.options.merge("sort" => "since")
      end
      it "should sort by the time when Twitter acount was created" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @cli.options = @cli.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @cli.options = @cli.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @cli.users("sferik", "pengwynn")
        $stdout.string.chomp.should == "pengwynn  sferik"
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
      stub_get("/1.1/users/show.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @cli.whois("sferik")
      a_get("/1.1/users/show.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @cli.whois("sferik")
      $stdout.string.should == <<-eos
ID           7505382
Name         Erik Michaels-Ober
Bio          Vagabond.
Location     San Francisco
Status       Not following
Last update  @goldman You're near my home town! Say hi to Woodstock for me. (7 months ago)
Since        Jul 16  2007 (4 years ago)
Tweets       7,890
Favorites    3,755
Listed       118
Following    212
Followers    2,262
URL          https://github.com/sferik
      eos
    end
    context "--csv" do
      before do
        @cli.options = @cli.options.merge("csv" => true)
      end
      it "should have the correct output" do
        @cli.whois("sferik")
        $stdout.string.should == <<-eos
ID,Verified,Name,Screen name,Bio,Location,Following,Last update,Lasted updated at,Since,Tweets,Favorites,Listed,Following,Followers,URL
7505382,false,Erik Michaels-Ober,sferik,Vagabond.,San Francisco,false,@goldman You're near my home town! Say hi to Woodstock for me.,2012-07-08 18:29:20 +0000,2007-07-16 12:59:01 +0000,7890,3755,118,212,2262,https://github.com/sferik
        eos
      end
    end
    context "--id" do
      before do
        @cli.options = @cli.options.merge("id" => true)
        stub_get("/1.1/users/show.json").
          with(:query => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @cli.whois("7505382")
        a_get("/1.1/users/show.json").
          with(:query => {:user_id => "7505382"}).
          should have_been_made
      end
    end
  end

end
