# encoding: utf-8
require 'helper'

describe T::Search do

  before do
    rcfile = RCFile.instance
    rcfile.path = fixture_path + "/.trc"
    @search = T::Search.new
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

  describe "#all" do
    before do
      stub_request(:get, "https://search.twitter.com/search.json").
        with(:query => {:q => "twitter", :rpp => "20"}).
        to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.all("twitter")
      a_request(:get, "https://search.twitter.com/search.json").
        with(:query => {:q => "twitter", :rpp => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.all("twitter")
      $stdout.string.should =~ /@JessRoveel/
      $stdout.string.should =~ /Pondre lo mas importante de Hamlet en Twitter para recordarlo mejor :D/
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.all("twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194521262415032320,2011-04-23 20:20:57 +0000,JessRoveel,Pondre lo mas importante de Hamlet en Twitter para recordarlo mejor :D
194521262326951936,2011-04-23 20:20:57 +0000,lauravgeest,Twitter doet het al 7 uur niet meer
194521262234669056,2011-04-23 20:20:57 +0000,Jenny_Bearx333,"I keep thinking that twitter is @instagram , and therefore double tap all the pics I like... #NotWorking"
194521262138204160,2011-04-23 20:20:57 +0000,misspoxtonX,RT @jordantaylorhi: twitter friends > twats at school
194521262134001665,2011-04-23 20:20:57 +0000,PatrickBrickman,RT @zeus30hightower: Too all Bama fans and followers my cousin mark Barron doesn't have a twitter so please disregard any tweets from that user
194521262129811456,2011-04-23 20:20:57 +0000,KolonelX,Ik refresh twitter op me telefoon terwijl ik tweetdeck voor me open heb staan
194521261852995586,2011-04-23 20:20:57 +0000,VLGPRLG5,"@mikeyway and you too RT @NimcyGD: @gerardway Get your ass back to twitter, okay? :3"
194521261756530689,2011-04-23 20:20:57 +0000,xRhiBabyx,Trying to persuade the boyf to get on twitter and failing. Help? @holly_haime @Ckwarburton @samwarburton_ @chrishaime @rowloboy
194521261630697473,2011-04-23 20:20:57 +0000,juliotrv,RT @lookinglassbr: Lançamentos outono-inverno 2012...CONFIRA em http://t.co/YAk8OXp7 http://t.co/fmmrVrbG
194521261571964928,2011-04-23 20:20:57 +0000,shanleyaustin27,RT @caaammmmi: @shanleyaustin27 .....and this hahahahaa http://t.co/wzCMx6ZU
194521261563580416,2011-04-23 20:20:57 +0000,Dame_Valuta,RT @Paiser10: Great @chelseafc training at Nou Camp! #cfc http://t.co/k00TnRyR
194521261488095232,2011-04-23 20:20:57 +0000,miss_indyiah,"smh, @IndianaHustle done turned into a twitter addict..fuck goin on lol ?"
194521261370650625,2011-04-23 20:20:57 +0000,CAROLINEWOLLER,"RT @Mark_Ingram28: To all Bama fans and followers, please unfollow and pay no attention to any user posing to be Mark Barron. My bro doesn't have a twitter!"
194521261370642432,2011-04-23 20:20:57 +0000,shelbytrenchdww,"RT @The90sLife: Admit it, we all have a cabinet that looks like this. http://t.co/gQEkQw5G"
194521261307727872,2011-04-23 20:20:57 +0000,kabos84,"RT @JF_q8: بالله  عليكم ،، مو عيب !!!



.. http://t.co/e29GV7Ow"
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.all("twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name       Text
194521262415032320  Apr 23  2011  @JessRoveel       Pondre lo mas importante ...
194521262326951936  Apr 23  2011  @lauravgeest      Twitter doet het al 7 uur...
194521262234669056  Apr 23  2011  @Jenny_Bearx333   I keep thinking that twit...
194521262138204160  Apr 23  2011  @misspoxtonX      RT @jordantaylorhi: twitt...
194521262134001665  Apr 23  2011  @PatrickBrickman  RT @zeus30hightower: Too ...
194521262129811456  Apr 23  2011  @KolonelX         Ik refresh twitter op me ...
194521261852995586  Apr 23  2011  @VLGPRLG5         @mikeyway and you too RT ...
194521261756530689  Apr 23  2011  @xRhiBabyx        Trying to persuade the bo...
194521261630697473  Apr 23  2011  @juliotrv         RT @lookinglassbr: Lançam...
194521261571964928  Apr 23  2011  @shanleyaustin27  RT @caaammmmi: @shanleyau...
194521261563580416  Apr 23  2011  @Dame_Valuta      RT @Paiser10: Great @chel...
194521261488095232  Apr 23  2011  @miss_indyiah     smh, @IndianaHustle done ...
194521261370650625  Apr 23  2011  @CAROLINEWOLLER   RT @Mark_Ingram28: To all...
194521261370642432  Apr 23  2011  @shelbytrenchdww  RT @The90sLife: Admit it,...
194521261307727872  Apr 23  2011  @kabos84          RT @JF_q8: بالله  عليكم ،...
        eos
      end
    end
    context "--number" do
      before do
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "1"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "200"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "145", :max_id => "194521261307727871"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results to 1" do
        @search.options = @search.options.merge("number" => 1)
        @search.all("twitter")
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "1"}).
          should have_been_made
      end
      it "should limit the number of results to 345" do
        @search.options = @search.options.merge("number" => 345)
        @search.all("twitter")
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "200"}).
          should have_been_made
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :rpp => "145", :max_id => "194521261307727871"}).
          should have_been_made
      end
    end
  end

  describe "#favorites" do
    before do
      stub_get("/1/favorites.json").
        with(:query => {:count => "200"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/favorites.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.favorites("twitter")
      a_get("/1/favorites.json").
        with(:query => {:count => "200"}).
        should have_been_made
      a_get("/1/favorites.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.favorites("twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.favorites("twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.favorites("twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/favorites.json").
          with(:query => {:count => "200"}).
          to_return(:status => 502)
        lambda do
          @search.favorites("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/favorites.json").
          with(:query => {:count => "200"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1/statuses/mentions.json").
        with(:query => {:count => "200"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/statuses/mentions.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.mentions("twitter")
      a_get("/1/statuses/mentions.json").
        with(:query => {:count => "200"}).
        should have_been_made
      a_get("/1/statuses/mentions.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.mentions("twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.mentions("twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.mentions("twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/mentions.json").
          with(:query => {:count => "200"}).
          to_return(:status => 502)
        lambda do
          @search.mentions("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/mentions.json").
          with(:query => {:count => "200"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#list" do
    before do
      stub_get("/1/lists/statuses.json").
        with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/lists/statuses.json").
        with(:query => {:count => "200", :max_id => "194546264212385792", :owner_screen_name => "testcli", :slug => "presidents"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.list("presidents", "twitter")
      a_get("/1/lists/statuses.json").
        with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).
        should have_been_made
      a_get("/1/lists/statuses.json").
        with(:query => {:count => "200", :max_id => "194546264212385792", :owner_screen_name => "testcli", :slug => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.list("presidents", "twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.list("presidents", "twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.list("presidents", "twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "with a user passed" do
      it "should request the correct resource" do
        @search.list("testcli/presidents", "twitter")
        a_get("/1/lists/statuses.json").
          with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).
          should have_been_made
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1/lists/statuses.json").
            with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"}).
            to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1/lists/statuses.json").
            with(:query => {:count => "200", :max_id => "194546264212385792", :owner_id => "7505382", :slug => "presidents"}).
            to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @search.list("7505382/presidents", "twitter")
          a_get("/1/lists/statuses.json").
            with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"}).
            should have_been_made
          a_get("/1/lists/statuses.json").
            with(:query => {:count => "200", :max_id => "194546264212385792", :owner_id => "7505382", :slug => "presidents"}).
            should have_been_made
        end
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/lists/statuses.json").
          with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).
          to_return(:status => 502)
        lambda do
          @search.list("presidents", "twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/lists/statuses.json").
          with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#retweets" do
    before do
      stub_get("/1/statuses/retweeted_by_me.json").
        with(:query => {:count => "200"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/statuses/retweeted_by_me.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.retweets("twitter")
      a_get("/1/statuses/retweeted_by_me.json").
        with(:query => {:count => "200"}).
        should have_been_made
      a_get("/1/statuses/retweeted_by_me.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.retweets("twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.retweets("twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.retweets("twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200"}).
          to_return(:status => 502)
        lambda do
          @search.retweets("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1/statuses/home_timeline.json").
        with(:query => {:count => "200"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/statuses/home_timeline.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.timeline("twitter")
      a_get("/1/statuses/home_timeline.json").
        with(:query => {:count => "200"}).
        should have_been_made
      a_get("/1/statuses/home_timeline.json").
        with(:query => {:count => "200", :max_id => "194546264212385792"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.timeline("twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.timeline("twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.timeline("twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200"}).
          to_return(:status => 502)
        lambda do
          @search.timeline("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#user" do
    before do
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:count => "200", :screen_name => "sferik"}).
        to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/statuses/user_timeline.json").
        with(:query => {:count => "200", :max_id => "194546264212385792", :screen_name => "sferik"}).
        to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.user("sferik", "twitter")
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:count => "200", :screen_name => "sferik"}).
        should have_been_made
      a_get("/1/statuses/user_timeline.json").
        with(:query => {:count => "200", :max_id => "194546264212385792", :screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.user("sferik", "twitter")
      $stdout.string.should =~ /@bartt/
      $stdout.string.should =~ /@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons\. Lot’s/
      $stdout.string.should =~ /fun\. Expect improvements in the weeks to come\./
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.user("sferik", "twitter")
        $stdout.string.should == <<-eos
ID,Posted at,Screen name,Text
194546727670390784,2011-04-23 22:02:09 +0000,bartt,"@noahlt @gaarf Yup, now owning @twitter -> FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come."
        eos
      end
    end
    context "--id" do
      before do
        @search.options = @search.options.merge("id" => true)
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "200", :user_id => "7505382"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "200", :max_id => "194546264212385792", :user_id => "7505382"}).
          to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @search.user("7505382", "twitter")
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "200", :user_id => "7505382"}).
          should have_been_made
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:count => "200", :max_id => "194546264212385792", :user_id => "7505382"}).
          should have_been_made
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.user("sferik", "twitter")
        $stdout.string.should == <<-eos
ID                  Posted at     Screen name  Text
194546727670390784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning...
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200"}).
          to_return(:status => 502)
        lambda do
          @search.user("sferik", "twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200"}).
          should have_been_made.times(3)
      end
    end
  end

end
