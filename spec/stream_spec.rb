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

    @tweetstream_client = double('TweetStream::Client').as_null_object

    @stream = T::Stream.new
    allow(@stream).to receive(:client) { @tweetstream_client }
    allow(@stream).to receive(:say).and_return

    allow(STDOUT).to receive(:tty?).and_return(true)
  end

	describe "#all" do
    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@tweetstream_client).to receive(:on_timeline_status).and_return
        allow(@tweetstream_client).to receive(:on_inited).and_yield

        @stream.should_receive(:say).with("ID,Posted at,Screen name,Text\n")
        @stream.all
      end

      it "outputs in CSV format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_csv_tweet).with(any_args)
        @stream.all
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@tweetstream_client).to receive(:on_inited).and_yield
        allow(@tweetstream_client).to receive(:on_timeline_status).and_return

        @stream.should_receive(:print_table).with(any_args)
        @stream.all
      end

      it "outputs in long text format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_table).with(any_args)
        @stream.all
      end
    end

    context "normal usage" do
      before :each do
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)
      end

      it "prints the tweet status" do
        @stream.should_receive(:print_message)
        @stream.all
      end
    end

    it "invokes TweetStream::Client#sample" do
      @tweetstream_client.should_receive(:sample)
      @stream.all
    end
  end

  describe "#matrix" do
    before :each do
      allow(@tweetstream_client).to receive(:on_timeline_status).
        and_yield(@status)
    end

    it "outputs the tweet status" do
      @stream.should_receive(:say).with(any_args)
      @stream.matrix
    end

    it "invokes TweetStream::Client.sample" do
      @tweetstream_client.should_receive(:sample)
      @stream.matrix
    end
  end

  describe "#search" do
    before :each do
      allow(@tweetstream_client).to receive(:on_timeline_status).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs in CSV format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return

        @stream.should_receive(:print_csv_tweet).with(any_args)
        @stream.search('t gem')
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs in long text format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_table).with(any_args)
        @stream.search('t gem')
      end
    end

    context "normal usage" do
      before :each do
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)
      end

      it "prints the tweet status" do
        @stream.should_receive(:print_message)
        @stream.search('t gem')
      end
    end

    it "performs a REST search when the stream initializes" do
      allow(@tweetstream_client).to receive(:on_timeline_status).and_return
      allow(@tweetstream_client).to receive(:on_inited).and_yield

      allow(T::Search).to receive(:new).and_return(t_class)
      t_class.should_receive(:all).with('t OR gem').and_return

      @stream.search('t', 'gem')
    end

    it "invokes TweetStream::Client#track" do
      allow(@tweetstream_client).to receive(:on_timeline_status).and_return

      @tweetstream_client.should_receive(:track).with(['t gem'])
      @stream.search('t gem')
    end
  end

  describe "#timeline" do
    before :each do
      allow(@tweetstream_client).to receive(:on_timeline_status).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs in CSV format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return

        @stream.should_receive(:print_csv_tweet).with(any_args)
        @stream.timeline
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs in long text format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_table).with(any_args)
        @stream.timeline
      end
    end

    context "normal usage" do
      before :each do
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)
      end

      it "prints the tweet status" do
        @stream.should_receive(:print_message)
        @stream.timeline
      end
    end

    it "performs a REST search when the stream initializes" do
      allow(@tweetstream_client).to receive(:on_timeline_status).and_return
      allow(@tweetstream_client).to receive(:on_inited).and_yield

      allow(T::CLI).to receive(:new).and_return(t_class)
      t_class.should_receive(:timeline).and_return

      @stream.timeline
    end

    it "invokes TweetStream::Client#userstream" do
      allow(@tweetstream_client).to receive(:on_timeline_status).and_return

      @tweetstream_client.should_receive(:userstream)
      @stream.timeline
    end
  end

  describe "#users" do
    before :each do
      allow(@tweetstream_client).to receive(:on_timeline_status).
        and_yield(@status)
    end

    context "--csv" do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@tweetstream_client).to receive(:on_timeline_status).and_return
        allow(@tweetstream_client).to receive(:on_inited).and_yield

        @stream.should_receive(:say).with("ID,Posted at,Screen name,Text\n")
        @stream.users('123')
      end

      it "outputs in CSV format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return

        @stream.should_receive(:print_csv_tweet).with(any_args)
        @stream.users('123')
      end
    end

    context "--long" do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it "outputs headings when the stream initializes" do
        allow(@tweetstream_client).to receive(:on_inited).and_yield
        allow(@tweetstream_client).to receive(:on_timeline_status).and_return

        @stream.should_receive(:print_table).with(any_args)
        @stream.users('123')
      end

      it "outputs in long text format" do
        allow(@tweetstream_client).to receive(:on_inited).and_return
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_table).with(any_args)
        @stream.users('123')
      end
    end

    context "normal usage" do
      before :each do
        allow(@tweetstream_client).to receive(:on_timeline_status).
          and_yield(@status)
      end

      it "prints the tweet status" do
        @stream.should_receive(:print_message)
        @stream.users('123')
      end
    end

    it "invokes TweetStream::Client#follow" do
      allow(@tweetstream_client).to receive(:on_timeline_status).and_return

      @tweetstream_client.should_receive(:follow).with([123, 456, 789])
      @stream.users('123', '456', '789')
    end
  end
end
