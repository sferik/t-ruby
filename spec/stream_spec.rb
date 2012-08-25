require 'helper'

describe T::Stream do
  before :all do
    @status = status_from_fixture("status.json")
  end

  before :each do
    T::RCFile.instance.path = fixture_path + "/.trc"

    @tweetstream_client = stub('TweetStream::Client').as_null_object

    @stream = T::Stream.new
    @stream.stub(:client) { @tweetstream_client }
  end


	describe '#all' do
    context '--csv' do
      before :each do
        @stream.options = @stream.options.merge("csv" => true)
        @stream.stub(:say).and_return
      end

      it 'outputs headings when the stream initializes' do
        @tweetstream_client.stub(:on_timeline_status).and_return
        @tweetstream_client.stub(:on_inited).and_yield

        @stream.should_receive(:say).with(any_args)
        @stream.all
      end

      it "outputs in CSV format" do
        @tweetstream_client.stub(:on_inited).and_return
        @tweetstream_client.stub(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_csv_status).with(any_args)
        @stream.all
      end
    end

    context '--long' do
      before :each do
        @stream.options = @stream.options.merge("long" => true)
      end

      it 'outputs headings when the stream initializes' do
        @tweetstream_client.stub(:on_inited).and_yield
        @tweetstream_client.stub(:on_timeline_status).and_return
        STDOUT.stub(:tty?).and_return(true)

        @stream.should_receive(:print_table).with(any_args)
        @stream.all
      end

      it "outputs in long text format" do
        @tweetstream_client.stub(:on_inited).and_return
        @tweetstream_client.stub(:on_timeline_status).
          and_yield(@status)

        @stream.should_receive(:print_table).with(any_args)
        @stream.all
      end
    end

    context 'normal usage' do
      before :each do
        @tweetstream_client.stub(:on_timeline_status).
          and_yield(@status)
      end

      it 'prints the tweet status' do
        @stream.should_receive(:print_message)
        @stream.all
      end
    end

    it 'invokes TweetStream::Client.sample' do
      @tweetstream_client.should_receive(:sample)
      @stream.all
    end
	end

  describe '#matrix' do
    before :each do
      @tweetstream_client.stub(:on_timeline_status).
        and_yield(@status)
    end

    it 'outputs the tweet status' do
      @stream.should_receive(:say).with(any_args)
      @stream.matrix
    end

    it 'invokes TweetStream::Client.sample' do
      @tweetstream_client.should_receive(:sample)
      @stream.stub(:say).and_return
      @stream.matrix
    end
  end
end