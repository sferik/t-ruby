# encoding: utf-8
require 'helper'

describe T::FormatHelpers do

  before :all do
    Timecop.freeze(Time.utc(2011, 11, 24, 16, 20, 0))
    T.utc_offset = 'PST'
  end

  after :all do
    T.utc_offset = nil
    Timecop.return
  end

  before do
    class Test; end
    @test = Test.new
    @test.extend(T::FormatHelpers)
  end

  describe "#distance_of_time_in_words_to_now" do
    it "returns \"less than a second\" if difference is less than a second" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 0))).should == "less than a second"
    end
    it "returns \"1 second\" if difference is a second" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 1))).should == "1 second"
    end
    it "returns \"2 seconds\" if difference is 2 seconds" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 2))).should == "2 seconds"
    end
    it "returns \"half a minute\" if difference is 30 seconds" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 30))).should == "half a minute"
    end
    it "returns \"less than a minute\" if difference is 40 seconds" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 40))).should == "less than a minute"
    end
    it "returns \"less than a minute\" if difference is 40 seconds" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 20, 40))).should == "less than a minute"
    end
    it "returns \"1 minute\" if difference is a minute" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 21, 0))).should == "1 minute"
    end
    it "returns \"2 minute\" if difference is 2 minutes" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 16, 21, 0))).should == "1 minute"
    end
    it "returns \"about an hour\" if difference is 45 minutes" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 17, 5, 0))).should == "about an hour"
    end
    it "returns \"2 hours\" if difference is 90 minutes" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 24, 17, 50, 0))).should == "about 2 hours"
    end
    it "returns \"1 day\" if difference is a day" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 25, 16, 20, 0))).should == "1 day"
    end
    it "returns \"2 day\" if difference is 2 days" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 11, 26, 16, 20, 0))).should == "2 days"
    end
    it "returns \"about a month\" if difference is a month" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2011, 12, 24, 16, 20, 0))).should == "about a month"
    end
    it "returns \"2 months\" if difference is 2 months" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2012, 1, 24, 16, 20, 0))).should == "2 months"
    end
    it "returns \"about a year\" if difference is 1 year" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2012, 11, 24, 16, 20, 0))).should == "about a year"
    end
    it "returns \"2 years\" if difference is 2 years" do
      @test.send(:distance_of_time_in_words_to_now, (Time.utc(2013, 11, 24, 16, 20, 0))).should == "2 years"
    end
  end

end
