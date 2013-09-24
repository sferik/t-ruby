require 'helper'

describe T::Stream do
  let(:t_class) {
    klass = Class.new
    allow(klass).to receive(:options=).and_return
    allow(klass).to receive(:options).and_return({})
    klass
  }

  before :all do
    @status = status_from_fixture("status.json")
  end

  before :each do
    T::RCFile.instance.path = fixture_path + "/.trc"
    @client = double('Twitter::Streaming::Client').as_null_object
    @stream = T::Stream.new
    allow(@stream).to receive(:client) { @client }
    allow(@stream).to receive(:say).and_return
    allow(STDOUT).to receive(:tty?).and_return(true)
  end

	describe "#all" do
    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end
      it "outputs headings when the stream initializes" do
        allow(@client).to receive(:sample).and_return
        allow(@client).to receive(:before_request).and_yield
        expect(@stream).to receive(:say).with("ID,Posted at,Screen name,Text\n")
        @stream.all
      end
      it "outputs in CSV format" do
        allow(@client).to receive(:before_request).and_return
        allow(@client).to receive(:sample).
          and_yield(@status)
        expect(@stream).to receive(:print_csv_tweet).with(any_args)
        @stream.all
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@client).to receive(:before_request).and_yield
        allow(@client).to receive(:sample).and_return
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.all
      end

      it "outputs in long text format" do
        allow(@client).to receive(:before_request).and_return
        allow(@client).to receive(:sample).
          and_yield(@status)
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.all
      end
    end

    context "normal usage" do
      before :each do
        allow(@client).to receive(:sample).
          and_yield(@status)
      end

      it "prints the tweet status" do
        expect(@stream).to receive(:print_message)
        @stream.all
      end
    end

    it "invokes Twitter::Streaming::Client#sample" do
      expect(@client).to receive(:sample)
      @stream.all
    end
  end

  describe "#matrix" do
    before :each do
      allow(@client).to receive(:sample).
        and_yield(@status)
    end

    it "outputs the tweet status" do
      expect(@stream).to receive(:say).with(any_args)
      @stream.matrix
    end

    it "invokes Twitter::Streaming::Client.sample" do
      expect(@client).to receive(:sample)
      @stream.matrix
    end
  end

  describe "#search" do
    before :each do
      allow(@client).to receive(:filter).with(:track => ["gem"]).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs in CSV format" do
        allow(@client).to receive(:before_request).and_return
        expect(@stream).to receive(:print_csv_tweet).with(any_args)
        @stream.search('gem')
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs in long text format" do
        allow(@client).to receive(:before_request).and_return
        allow(@client).to receive(:filter).with(:track => ["gem"]).
          and_yield(@status)
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.search('gem')
      end
    end

    context "normal usage" do
      before :each do
        allow(@client).to receive(:filter).with(:track => ["gem"]).
          and_yield(@status)
      end
      it "prints the tweet status" do
        expect(@stream).to receive(:print_message)
        @stream.search('gem')
      end
    end

    it "performs a REST search when the stream initializes" do
      allow(@client).to receive(:filter).and_return
      allow(@client).to receive(:before_request).and_yield
      allow(T::Search).to receive(:new).and_return(t_class)
      expect(t_class).to receive(:all).with('t OR gem').and_return
      @stream.search('t', 'gem')
    end

    it "invokes Twitter::Streaming::Client#filter" do
      allow(@client).to receive(:filter).and_return
      expect(@client).to receive(:filter).with(:track => ['gem'])
      @stream.search('gem')
    end
  end

  describe "#timeline" do
    before :each do
      allow(@client).to receive(:user).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs in CSV format" do
        allow(@client).to receive(:before_request).and_return
        expect(@stream).to receive(:print_csv_tweet).with(any_args)
        @stream.timeline
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs in long text format" do
        allow(@client).to receive(:before_request).and_return
        allow(@client).to receive(:user).
          and_yield(@status)
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.timeline
      end
    end

    context "normal usage" do
      before :each do
        allow(@client).to receive(:user).
          and_yield(@status)
      end

      it "prints the tweet status" do
        expect(@stream).to receive(:print_message)
        @stream.timeline
      end
    end

    it "performs a REST search when the stream initializes" do
      allow(@client).to receive(:user).and_return
      allow(@client).to receive(:before_request).and_yield
      allow(T::CLI).to receive(:new).and_return(t_class)
      expect(t_class).to receive(:timeline).and_return

      @stream.timeline
    end

    it "invokes Twitter::Streaming::Client#userstream" do
      allow(@client).to receive(:user).and_return
      expect(@client).to receive(:user)
      @stream.timeline
    end
  end

  describe "#users" do
    before :each do
      allow(@client).to receive(:follow).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@client).to receive(:follow).and_return
        allow(@client).to receive(:before_request).and_yield
        expect(@stream).to receive(:say).with("ID,Posted at,Screen name,Text\n")
        @stream.users('123')
      end

      it "outputs in CSV format" do
        allow(@client).to receive(:before_request).and_return
        expect(@stream).to receive(:print_csv_tweet).with(any_args)
        @stream.users('123')
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@client).to receive(:before_request).and_yield
        allow(@client).to receive(:follow).and_return
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.users('123')
      end

      it "outputs in long text format" do
        allow(@client).to receive(:before_request).and_return
        allow(@client).to receive(:follow).
          and_yield(@status)
        expect(@stream).to receive(:print_table).with(any_args)
        @stream.users('123')
      end
    end

    context "normal usage" do
      before :each do
        allow(@client).to receive(:follow).
          and_yield(@status)
      end

      it "prints the tweet status" do
        expect(@stream).to receive(:print_message)
        @stream.users('123')
      end
    end

    it "invokes Twitter::Streaming::Client#follow" do
      allow(@client).to receive(:follow).and_return
      expect(@client).to receive(:follow).with([123, 456, 789])
      @stream.users('123', '456', '789')
    end
  end
end
