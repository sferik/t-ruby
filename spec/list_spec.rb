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
      $stdout.string.should =~ /@testcli added 1 member to the list "presidents"\./
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

  describe "#members" do
    before do
      stub_get("/1/lists/members.json").
        with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "testcli", :skip_status => "true", :slug => "presidents"}).
        to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @list.members("presidents")
      a_get("/1/lists/members.json").
        with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "testcli", :skip_status => "true", :slug => "presidents"}).
        should have_been_made
    end
    it "should have the correct output" do
      @list.members("presidents")
      $stdout.string.chomp.rstrip.should == "@pengwynn  @sferik"
    end
    context "--created" do
      before do
        @list.options = @list.options.merge(:created => true)
      end
      it "should sort by the time wshen Twitter account was created" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "--favorites" do
      before do
        @list.options = @list.options.merge(:favorites => true)
      end
      it "should sort by number of favorites" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@pengwynn  @sferik"
      end
    end
    context "--followers" do
      before do
        @list.options = @list.options.merge(:followers => true)
      end
      it "should sort by number of followers" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "--friends" do
      before do
        @list.options = @list.options.merge(:friends => true)
      end
      it "should sort by number of friends" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "--listed" do
      before do
        @list.options = @list.options.merge(:listed => true)
      end
      it "should sort by number of list memberships" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "--long" do
      before do
        @list.options = @list.options.merge(:long => true)
      end
      it "should list in long format" do
        @list.members("presidents")
        $stdout.string.should == <<-eos
ID          Since         Tweets  Favorites  Listed  Following  Followers  Screen name  Name
14,100,886  Mar  8  2008  3,913   32         185     1,871      2,767      @pengwynn    Wynn Netherland
7,505,382   Jul 16  2007  2,962   727        29      88         898        @sferik      Erik Michaels-Ober
        eos
      end
    end
    context "--reverse" do
      before do
        @list.options = @list.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "--tweets" do
      before do
        @list.options = @list.options.merge(:tweets => true)
      end
      it "should sort by number of Tweets" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@sferik    @pengwynn"
      end
    end
    context "with a screen name passed" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @list.members("sferik", "presidents")
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @list.members("presidents")
        $stdout.string.chomp.rstrip.should == "@pengwynn  @sferik"
      end
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
      $stdout.string.should =~ /@testcli removed 1 member from the list "presidents"\./
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
        @list.options = @list.options.merge(:long => true)
      end
      it "should list in long format" do
        @list.timeline("presidents")
        $stdout.string.should == <<-eos
ID                       Posted at     Screen name    Text
194,548,121,416,630,272  Apr 23  2011  @natevillegas  RT @gelobautista #riordan RT @WilI_Smith: Yesterday is history. Tomorrow is a mystery. Today is a gift. That's why it's called the present.
194,547,993,607,806,976  Apr 23  2011  @TD            @kelseysilver how long will you be in town?
194,547,987,593,183,233  Apr 23  2011  @rusashka      @maciej hahaha :) @gpena together we're going to cover all core 28 languages!
194,547,824,690,597,888  Apr 23  2011  @fat           @stevej @xc i'm going to picket when i get back.
194,547,658,562,605,057  Apr 23  2011  @wil           @0x9900 @paulnivin http://t.co/bwVdtAPe
194,547,528,430,137,344  Apr 23  2011  @wangtian      @tianhonghe @xiangxin72 oh, you can even order specific items?
194,547,402,550,689,793  Apr 23  2011  @shinypb       @kpk Pfft, I think you're forgetting mechanical television, which depended on a clever German. http://t.co/JvLNQCDm @skilldrick @hoverbird
194,547,260,233,760,768  Apr 23  2011  @0x9900        @wil @paulnivin if you want to take you seriously don't say daemontools!
194,547,084,349,804,544  Apr 23  2011  @kpk           @shinypb @skilldrick @hoverbird invented it
194,546,876,782,092,291  Apr 23  2011  @skilldrick    @shinypb Well played :) @hoverbird
194,546,811,480,969,217  Apr 23  2011  @sam           Can someone project the date that I'll get a 27" retina display?
194,546,738,810,458,112  Apr 23  2011  @shinypb       @skilldrick @hoverbird Wow, I didn't even know they *had* TV in Britain.
194,546,727,670,390,784  Apr 23  2011  @bartt         @noahlt @gaarf Yup, now owning @twitter -&gt; FB from FE to daemons. Lot’s of fun. Expect improvements in the weeks to come.
194,546,649,203,347,456  Apr 23  2011  @skilldrick    @hoverbird @shinypb You guys must be soooo old, I don't remember the words to the duck tales intro at all.
194,546,583,608,639,488  Apr 23  2011  @sean          @mep Thanks for coming by. Was great to have you.
194,546,388,707,717,120  Apr 23  2011  @hoverbird     @shinypb @trammell it's all suck a "duck blur" sometimes.
194,546,264,212,385,793  Apr 23  2011  @kelseysilver  San Francisco here I come! (@ Newark Liberty International Airport (EWR) w/ 92 others) http://t.co/eoLANJZw
        eos
      end
    end
    context "--number" do
      before do
        @list.options = @list.options.merge(:number => 1)
        stub_get("/1/lists/statuses.json").
          with(:query => {:owner_screen_name => "testcli", :per_page => "1", :slug => "presidents", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should limit the number of results" do
        @list.timeline("presidents")
        a_get("/1/lists/statuses.json").
          with(:query => {:owner_screen_name => "testcli", :per_page => "1", :slug => "presidents", :include_entities => "false"}).
          should have_been_made
      end
    end
    context "--reverse" do
      before do
        @list.options = @list.options.merge(:reverse => true)
      end
      it "should reverse the order of the sort" do
        @list.timeline("presidents")
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
        stub_get("/1/lists/statuses.json").
          with(:query => {:owner_screen_name => "sferik", :per_page => "20", :slug => "presidents", :include_entities => "false"}).
          to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @list.timeline("sferik", "presidents")
        a_get("/1/lists/statuses.json").
          with(:query => {:owner_screen_name => "sferik", :per_page => "20", :slug => "presidents", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @list.timeline("sferik", "presidents")
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

end
