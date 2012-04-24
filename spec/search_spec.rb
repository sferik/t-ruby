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
        with(:query => {:q => "twitter", :include_entities => "false", :rpp => "20"}).
        to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.all("twitter")
      a_request(:get, "https://search.twitter.com/search.json").
        with(:query => {:q => "twitter", :include_entities => "false", :rpp => "20"}).
        should have_been_made
    end
    it "should have the correct output" do
      @search.all("twitter")
      $stdout.string.should == <<-eos
          JessRoveel: Pondre lo mas importante de Hamlet en Twitter para recordarlo mejor :D (7 months ago)
         lauravgeest: Twitter doet het al 7 uur niet meer (7 months ago)
      Jenny_Bearx333: I keep thinking that twitter is @instagram , and therefore double tap all the pics I like... #NotWorking (7 months ago)
         misspoxtonX: RT @jordantaylorhi: twitter friends &gt; twats at school (7 months ago)
     PatrickBrickman: RT @zeus30hightower: Too all Bama fans and followers my cousin mark Barron doesn't have a twitter so please disregard any tweets from that user (7 months ago)
            KolonelX: Ik refresh twitter op me telefoon terwijl ik tweetdeck voor me open heb staan (7 months ago)
            VLGPRLG5: @mikeyway and you too RT @NimcyGD: @gerardway Get your ass back to twitter, okay? :3 (7 months ago)
           xRhiBabyx: Trying to persuade the boyf to get on twitter and failing. Help? @holly_haime @Ckwarburton @samwarburton_ @chrishaime @rowloboy (7 months ago)
            juliotrv: RT @lookinglassbr: Lançamentos outono-inverno 2012...CONFIRA em http://t.co/YAk8OXp7 http://t.co/fmmrVrbG (7 months ago)
     shanleyaustin27: RT @caaammmmi: @shanleyaustin27 .....and this hahahahaa http://t.co/wzCMx6ZU (7 months ago)
         Dame_Valuta: RT @Paiser10: Great @chelseafc training at Nou Camp! #cfc http://t.co/k00TnRyR (7 months ago)
        miss_indyiah: smh, @IndianaHustle done turned into a twitter addict..fuck goin on lol ? (7 months ago)
      CAROLINEWOLLER: RT @Mark_Ingram28: To all Bama fans and followers, please unfollow and pay no attention to any user posing to be Mark Barron. My bro doesn't have a twitter! (7 months ago)
     shelbytrenchdww: RT @The90sLife: Admit it, we all have a cabinet that looks like this. http://t.co/gQEkQw5G (7 months ago)
             kabos84: RT @JF_q8: بالله  عليكم ،، مو عيب !!! .. http://t.co/e29GV7Ow (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.all("twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name       Text
194,521,262,415,032,320  Apr 23  2011  @JessRoveel       Pondre lo mas importante de Hamlet en Twitter para recordarlo mejor :D
194,521,262,326,951,936  Apr 23  2011  @lauravgeest      Twitter doet het al 7 uur niet meer
194,521,262,234,669,056  Apr 23  2011  @Jenny_Bearx333   I keep thinking that twitter is @instagram , and therefore double tap all the pics I like... #NotWorking
194,521,262,138,204,160  Apr 23  2011  @misspoxtonX      RT @jordantaylorhi: twitter friends &gt; twats at school
194,521,262,134,001,665  Apr 23  2011  @PatrickBrickman  RT @zeus30hightower: Too all Bama fans and followers my cousin mark Barron doesn't have a twitter so please disregard any tweets from that user
194,521,262,129,811,456  Apr 23  2011  @KolonelX         Ik refresh twitter op me telefoon terwijl ik tweetdeck voor me open heb staan
194,521,261,852,995,586  Apr 23  2011  @VLGPRLG5         @mikeyway and you too RT @NimcyGD: @gerardway Get your ass back to twitter, okay? :3
194,521,261,756,530,689  Apr 23  2011  @xRhiBabyx        Trying to persuade the boyf to get on twitter and failing. Help? @holly_haime @Ckwarburton @samwarburton_ @chrishaime @rowloboy
194,521,261,630,697,473  Apr 23  2011  @juliotrv         RT @lookinglassbr: Lançamentos outono-inverno 2012...CONFIRA em http://t.co/YAk8OXp7 http://t.co/fmmrVrbG
194,521,261,571,964,928  Apr 23  2011  @shanleyaustin27  RT @caaammmmi: @shanleyaustin27 .....and this hahahahaa http://t.co/wzCMx6ZU
194,521,261,563,580,416  Apr 23  2011  @Dame_Valuta      RT @Paiser10: Great @chelseafc training at Nou Camp! #cfc http://t.co/k00TnRyR
194,521,261,488,095,232  Apr 23  2011  @miss_indyiah     smh, @IndianaHustle done turned into a twitter addict..fuck goin on lol ?
194,521,261,370,650,625  Apr 23  2011  @CAROLINEWOLLER   RT @Mark_Ingram28: To all Bama fans and followers, please unfollow and pay no attention to any user posing to be Mark Barron. My bro doesn't have a twitter!
194,521,261,370,642,432  Apr 23  2011  @shelbytrenchdww  RT @The90sLife: Admit it, we all have a cabinet that looks like this. http://t.co/gQEkQw5G
194,521,261,307,727,872  Apr 23  2011  @kabos84          RT @JF_q8: بالله  عليكم ،، مو عيب !!! .. http://t.co/e29GV7Ow
        eos
      end
    end
    context "--number" do
      before do
        @search.options = @search.options.merge(:number => 1)
        stub_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :include_entities => "false", :rpp => "1"}).
          to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @search.all("twitter")
        a_request(:get, "https://search.twitter.com/search.json").
          with(:query => {:q => "twitter", :include_entities => "false", :rpp => "1"}).
          should have_been_made
      end
    end
  end

  describe "#favorites" do
    before do
      1.upto(16).each do |page|
        stub_get("/1/favorites.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
    end
    it "should request the correct resource" do
      @search.favorites("twitter")
      1.upto(16).each do |page|
        a_get("/1/favorites.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          should have_been_made
      end
    end
    it "should have the correct output" do
      @search.favorites("twitter")
      $stdout.string.should == <<-eos
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.favorites("twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name  Text
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/favorites.json").
          with(:query => {:count => "200", :page => "16"}).
          to_return(:status => 502)
        lambda do
          @search.favorites("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/favorites.json").
          with(:query => {:count => "200", :page => "16"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#mentions" do
    before do
      1.upto(16).each do |page|
        stub_get("/1/statuses/mentions.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
    end
    it "should request the correct resource" do
      @search.mentions("twitter")
      1.upto(16).each do |page|
        a_get("/1/statuses/mentions.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          should have_been_made
      end
    end
    it "should have the correct output" do
      @search.mentions("twitter")
      $stdout.string.should == <<-eos
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.mentions("twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name  Text
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/mentions.json").
          with(:query => {:count => "200", :page => "16"}).
          to_return(:status => 502)
        lambda do
          @search.mentions("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/mentions.json").
          with(:query => {:count => "200", :page => "16"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#retweets" do
    before do
      1.upto(16).each do |page|
        stub_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
    end
    it "should request the correct resource" do
      @search.retweets("twitter")
      1.upto(16).each do |page|
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          should have_been_made
      end
    end
    it "should have the correct output" do
      @search.retweets("twitter")
      $stdout.string.should == <<-eos
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.retweets("twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name  Text
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200", :page => "16"}).
          to_return(:status => 502)
        lambda do
          @search.retweets("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/retweeted_by_me.json").
          with(:query => {:count => "200", :page => "16"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#timeline" do
    before do
      1.upto(16).each do |page|
        stub_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
    end
    it "should request the correct resource" do
      @search.timeline("twitter")
      1.upto(16).each do |page|
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200", :page => "#{page}"}).
          should have_been_made
      end
    end
    it "should have the correct output" do
      @search.timeline("twitter")
      $stdout.string.should == <<-eos
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.timeline("twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name  Text
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200", :page => "16"}).
          to_return(:status => 502)
        lambda do
          @search.timeline("twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/home_timeline.json").
          with(:query => {:count => "200", :page => "16"}).
          should have_been_made.times(3)
      end
    end
  end

  describe "#user" do
    before do
      1.upto(16).each do |page|
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200", :page => "#{page}"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
    end
    it "should request the correct resource" do
      @search.user("sferik", "twitter")
      1.upto(16).each do |page|
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200", :page => "#{page}"}).
          should have_been_made
      end
    end
    it "should have the correct output" do
      @search.user("sferik", "twitter")
      $stdout.string.should == <<-eos
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
               bartt: @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come. (7 months ago)
      eos
    end
    context "--long" do
      before do
        @search.options = @search.options.merge(:long => true)
      end
      it "should list in long format" do
        @search.user("sferik", "twitter")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name  Text
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,727,670,390,784  Apr 23  2011  @bartt       @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
        eos
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200", :page => "16"}).
          to_return(:status => 502)
        lambda do
          @search.user("sferik", "twitter")
        end.should raise_error("Twitter is down or being upgraded.")
        a_get("/1/statuses/user_timeline.json").
          with(:query => {:screen_name => "sferik", :count => "200", :page => "16"}).
          should have_been_made.times(3)
      end
    end
  end

end
