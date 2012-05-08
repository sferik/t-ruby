# encoding: utf-8
require 'helper'

describe T do

  describe "#env" do
    before do
      T.env = "value"
    end
    after do
      T.env = "test"
    end
    it "returns the value" do
      T.env.should == "value"
    end
    it "is inquirable" do
      T.env.value?.should be_true
    end
  end

  describe "#env=" do
    after do
      T.env = "test"
    end
    it "sets the value" do
      T.env = "value"
      T.env.should == "value"
    end
  end

end
