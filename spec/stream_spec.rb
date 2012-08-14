require 'helper'

describe T::Stream do
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
        @tweetstream_client.stub(:on_timeline_status).
          and_yield(fixture("status.json"))
      end

      it "should output in CSV format" do
        @stream.should_receive(:print_csv_status).with(any_args)
        @stream.all
      end
    end

    context '--long' do
    end

    it 'invokes TweetStream::Client.sample' do
      @tweetstream_client.should_receive(:sample)
      @stream.all
    end
	end
end