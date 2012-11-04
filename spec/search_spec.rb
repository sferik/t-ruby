# encoding: utf-8
require 'helper'

describe T::Search do

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
    @search = T::Search.new
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

  describe "#all" do
    before do
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "20"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "17"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "14"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "11"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "8"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "5"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "2"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.all("twitter")
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "20"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "17"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "14"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "11"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "8"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "5"})).to have_been_made
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :max_id => "246666260270702591", :rpp => "2"})).to have_been_made
    end
    it "should have the correct output" do
      @search.all("twitter")
      expect($stdout.string).to eq <<-eos

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

\e[1m\e[33m   @richrad\e[0m
   Bubble Mailer #freebandnames

\e[1m\e[33m   @dswordsNshields\e[0m
   Hair of the Frog

   (seriously, think about it)

   #freebandnames

\e[1m\e[33m   @StrongPROGress\e[0m
   #FreeBandNames Asterisks and Thunderstorms

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.all("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
247827742178021376,2012-09-17 22:41:52 +0000,richrad,Bubble Mailer #freebandnames
247811706061979648,2012-09-17 21:38:09 +0000,dswordsNshields,"Hair of the Frog 

(seriously, think about it) 

#freebandnames"
246666260270702592,2012-09-14 17:46:33 +0000,StrongPROGress,#FreeBandNames Asterisks and Thunderstorms
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.all("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name       Text
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
247827742178021376  Sep 17 14:41  @richrad          Bubble Mailer #freebandnames
247811706061979648  Sep 17 13:38  @dswordsNshields  Hair of the Frog  (seriou...
246666260270702592  Sep 14 09:46  @StrongPROGress   #FreeBandNames Asterisks ...
        eos
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "1"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "200"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "200", :max_id => "246666260270702591"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        (3..198).step(3).to_a.each do |count|
          stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => count, :max_id => "246666260270702591"}).to_return(:body => fixture("search.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
      end
      it "should limit the number of results to 1" do
        @search.options = @search.options.merge("number" => 1)
        @search.all("twitter")
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "1"})).to have_been_made
      end
      it "should limit the number of results to 345" do
        @search.options = @search.options.merge("number" => 345)
        @search.all("twitter")
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "200"})).to have_been_made
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => "200", :max_id => "246666260270702591"})).to have_been_made.times(48)
        (3..198).step(3).to_a.each do |count|
          expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => count, :max_id => "246666260270702591"})).to have_been_made
        end
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => 20}).to_return(:body => fixture("search_with_entities.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :rpp => 5, :max_id => 264784855672442882}).to_return(:body => fixture("search_with_entities.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :rpp => 20}).to_return(:body => fixture("search_with_entities.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :rpp => 5, :max_id => 264784855672442882}).to_return(:body => fixture("search_with_entities.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.all("twitter")
        expect($stdout.string).to include("http://t.co/fwZfnEaA")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.all("twitter")
        expect($stdout.string).to include("http://semver.org")
      end
    end

  end

  describe "#favorites" do
    before do
      stub_get("/1.1/favorites/list.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.favorites("twitter")
      expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "should have the correct output" do
      @search.favorites("twitter")
      expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.favorites("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.favorites("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.favorites("twitter")
        expect($stdout.string).to include("https://t.co/I17jUTu2")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.favorites("twitter")
        expect($stdout.string).to include("https://twitter.com/sferik/status/243988000076337152")
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.favorites("twitter")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @search.favorites("sferik", "twitter")
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"})).to have_been_made
      end
      it "should have the correct output" do
        @search.favorites("sferik", "twitter")
        expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

        eos
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @search.favorites("7505382", "twitter")
          expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"})).to have_been_made
        end
        it "should have the correct output" do
          @search.favorites("7505382", "twitter")
          expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

          eos
        end
      end
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.mentions("twitter")
      expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "should have the correct output" do
      @search.mentions("twitter")
      expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.mentions("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.mentions("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.mentions("twitter")
        expect($stdout.string).to include("https://t.co/I17jUTu2")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.mentions("twitter")
        expect($stdout.string).to include("https://twitter.com/sferik/status/243988000076337152")
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.mentions("twitter")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
  end

  describe "#list" do
    before do
      stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.list("presidents", "twitter")
      expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
      expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
    end
    it "should have the correct output" do
      @search.list("presidents", "twitter")
      expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to include("https://t.co/I17jUTu2")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.list("presidents", "twitter")
        expect($stdout.string).to include("https://dev.twitter.com/docs/api/post/direct_messages/destroy")
      end
    end
    context "with a user passed" do
      it "should request the correct resource" do
        @search.list("testcli/presidents", "twitter")
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_id => "7505382", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @search.list("7505382/presidents", "twitter")
          expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"})).to have_been_made
          expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_id => "7505382", :slug => "presidents"})).to have_been_made
        end
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:status => 502)
        expect do
          @search.list("presidents", "twitter")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made.times(3)
      end
    end
  end

  describe "#retweets" do
    before do
      stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.retweets("mosaic")
      expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"})).to have_been_made
      expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"})).to have_been_made.times(2)
    end
    it "should have the correct output" do
      @search.retweets("mosaic")
      expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.retweets("mosaic")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.retweets("mosaic")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name   Text
244108728834592770  Sep  7 08:23  @calebelston  RT @olivercameron: Mosaic loo...
        eos
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.retweets("mosaic")
        expect($stdout.string).to include("http://t.co/A8013C9k")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.retweets("mosaic")
        expect($stdout.string).to include("http://heymosaic.com/i/1Z8ssK")
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"}).to_return(:status => 502)
        expect do
          @search.retweets("mosaic")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @search.retweets("sferik", "mosaic")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"})).to have_been_made.times(2)
      end
      it "should have the correct output" do
        @search.retweets("sferik", "mosaic")
        expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

        eos
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @search.retweets("7505382", "mosaic")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"})).to have_been_made.times(2)
        end
        it "should have the correct output" do
          @search.retweets("7505382", "mosaic")
          expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @calebelston\e[0m
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

          eos
        end
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.timeline("twitter")
      expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "should have the correct output" do
      @search.timeline("twitter")
      expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.timeline("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--exclude=replies" do
      before do
        @search.options = @search.options.merge("exclude" => "replies")
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should exclude replies" do
        @search.timeline
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true"})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true", :max_id => "244099460672679937"})).to have_been_made
      end
    end
    context "--exclude=retweets" do
      before do
        @search.options = @search.options.merge("exclude" => "retweets")
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should exclude retweets" do
        @search.timeline
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false"})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false", :max_id => "244099460672679937"})).to have_been_made
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.timeline("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "--decode_urls" do
      before(:each) do
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :include_entities => 1}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should not decode urls without given the explicit option" do
        @search.timeline("twitter")
        expect($stdout.string).to include("https://t.co/I17jUTu2")
      end
      it "should decode the urls correctly" do
        @search.options = @search.options.merge("decode_urls" => true)
        @search.timeline("twitter")
        expect($stdout.string).to include("https://dev.twitter.com/docs/api/post/direct_messages/destroy")
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.timeline("twitter")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @search.timeline("sferik", "twitter")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"})).to have_been_made
      end
      it "should have the correct output" do
        @search.timeline("sferik", "twitter")
        expect($stdout.string).to eq <<-eos
\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

\e[1m\e[33m   @sferik\e[0m
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

        eos
      end
      context "--csv" do
        before do
          @search.options = @search.options.merge("csv" => true)
        end
        it "should output in CSV format" do
          @search.timeline("sferik", "twitter")
          expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
          eos
        end
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        end
        it "should request the correct resource" do
          @search.timeline("7505382", "twitter")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"})).to have_been_made
        end
      end
      context "--long" do
        before do
          @search.options = @search.options.merge("long" => true)
        end
        it "should output in long format" do
          @search.timeline("sferik", "twitter")
          expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
          eos
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik", :count => "200"}).to_return(:status => 502)
          expect do
            @search.timeline("sferik", "twitter")
          end.to raise_error("Twitter is down or being upgraded.")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik", :count => "200"})).to have_been_made.times(3)
        end
      end
    end
  end

  describe "#users" do
    before do
      stub_get("/1.1/users/search.json").with(:query => {:page => "1", :q => "Erik"}).to_return(:body => fixture("users.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik"}).to_return(:body => fixture("empty_array.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @search.users("Erik")
      1.upto(50).each do |page|
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "1", :q => "Erik"})).to have_been_made
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik"})).to have_been_made
      end
    end
    it "should have the correct output" do
      @search.users("Erik")
      expect($stdout.string.chomp).to eq "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "should output in CSV format" do
        @search.users("Erik")
        expect($stdout.string).to eq <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland ⚡
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "should output in long format" do
        @search.users("Erik")
        expect($stdout.string).to eq <<-eos
ID        Since         Last tweeted at  Tweets  Favorites  Listed  Following...
14100886  Mar  8  2008  Jul  7 12:33       6940        192     358       3427...
 7505382  Jul 16  2007  Jul  8 10:29       7890       3755     118        212...
        eos
      end
    end
    context "--reverse" do
      before do
        @search.options = @search.options.merge("reverse" => true)
      end
      it "should reverse the order of the sort" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @search.options = @search.options.merge("sort" => "favorites")
      end
      it "should sort by number of favorites" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @search.options = @search.options.merge("sort" => "followers")
      end
      it "should sort by number of followers" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @search.options = @search.options.merge("sort" => "friends")
      end
      it "should sort by number of friends" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @search.options = @search.options.merge("sort" => "listed")
      end
      it "should sort by number of list memberships" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @search.options = @search.options.merge("sort" => "since")
      end
      it "should sort by the time wshen Twitter account was created" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @search.options = @search.options.merge("sort" => "tweets")
      end
      it "should sort by number of Tweets" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @search.options = @search.options.merge("sort" => "tweeted")
      end
      it "should sort by the time of the last Tweet" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @search.options = @search.options.merge("unsorted" => true)
      end
      it "should not be sorted" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik", }).to_return(:status => 502)
        expect do
          @search.users("Erik")
        end.to raise_error("Twitter is down or being upgraded.")
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik", })).to have_been_made.times(3)
      end
    end
  end

end
