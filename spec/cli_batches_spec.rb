# encoding: utf-8
require 'helper'

describe T::CLI do

  before :all do
    Timecop.freeze(Time.utc(2011, 11, 24, 16, 20, 0))
    T.utc_offset = 'PST'
  end

  before do
    T::RCFile.instance.path = fixture_path + '/.trc'
    @cli = T::CLI.new
    @cli.options = @cli.options.merge('color' => 'always')
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    T::RCFile.instance.reset
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  after :all do
    T.utc_offset = nil
    Timecop.return
  end

  def stubby_tweets(x_id, y_id)
    (x_id..y_id).collect { |i| {:id => i, :created_at => Time.now - ((y_id - i) * 100)} }.reverse.to_json
  end

  describe '#timeline with :number in excess of 200' do
    before do
      @cli.options = @cli.options.merge('csv' => true, 'number' => 300)      
    end
    context 'no tweets' do
      before do
        stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'}).to_return(:body => fixture('empty_array.json'), :headers => {:content_type => 'application/json; charset=utf-8'})
      end
      it 'sends :count => 200, independent of the :number option' do
        @cli.timeline
        expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'})).to have_been_made
      end
    end
    context 'an exact response: 300 tweets total for 300 tweets requested' do
      before do
        stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'}).to_return(:body => stubby_tweets(101, 300), :headers => {:content_type => 'application/json; charset=utf-8'})
        stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '100', :max_id => 100, :include_entities => 'false'}).to_return(:body => stubby_tweets(1, 100), :headers => {:content_type => 'application/json; charset=utf-8'})
      end
      it 'fetches twice and decrements :count accordingly' do
        @cli.timeline        
        expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'})).to have_been_made
        expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '100', :include_entities => 'false', :max_id => 100})).to have_been_made
      end
      it 'has output' do
        @cli.timeline   
        expect($stdout.string.split("\n").count).to eq 301
      end
    end
    context 'error-handling' do
      before do
        @cli.options = @cli.options.merge('csv' => true, 'number' => 1000)      
      end
      context 'errors out before any tweets are fetched' do
        before do 
          stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'}).to_return(:status => 502, :headers => {:content_type => 'application/json; charset=utf-8'})
        end
        it 'tries 3 times and raises an error as expected' do
          expect do
            @cli.timeline
          end.to raise_error(Twitter::Error::BadGateway)
          expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'})).to have_been_made.times(3)
          expect($stdout.string.split("\n").count).to eq 0
        end
      end
      context 'errors out after some tweets are fetched' do
        before do 
          stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'}).to_return(:body => stubby_tweets(801, 1000), :headers => {:content_type => 'application/json; charset=utf-8'})
          stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :max_id => 800, :include_entities => 'false'}).to_return(:status => 502, :headers => {:content_type => 'application/json; charset=utf-8'})
        end
        it 'tries 3 times and swallows the error' do
          @cli.timeline
          expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :max_id => 800, :include_entities => 'false'})).to have_been_made.times(3)
        end
        it 'outputs the 200 tweets it received' do
          @cli.timeline
          str = $stdout.string.split("\n")
          expect(str.count).to eq 201
          expect(str.last).to match(/^801/)
        end
      end
    end

    describe '--max_results set to true' do      
      before do
        @cli.options = @cli.options.merge('csv' => true, 'max_results' => true, 'number' => nil)
      end
      describe 'relation to :number option' do
        before do
          stub_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'}).to_return(:body => fixture('empty_array.json'), :headers => {:content_type => 'application/json; charset=utf-8'})
        end
        it 'overrides :number and sets :count to its maximum allowed value' do
          @cli.timeline
          expect(a_get('/1.1/statuses/home_timeline.json').with(:query => {:count => '200', :include_entities => 'false'})).to have_been_made
        end
      end

      context '#user_timeline' do 
        describe 'maxes out at 3200 tweets received' do
          before do
            q_opts = {:count => '200', :include_entities => 'false', :screen_name => 'ev'}
            (0..17).each do |t|
              y = 200 * (17 - t)
              q_opts[:max_id] = y if t > 0
              x = y - 199
              stub_get('/1.1/statuses/user_timeline.json').with(:query => q_opts).to_return(:body => stubby_tweets(x, y), :headers => {:content_type => 'application/json; charset=utf-8'})
            end
          end
          it 'outputs 3201 lines' do
            @cli.timeline('ev')
            str = $stdout.string.split("\n")
            expect(str.count).to eq 3201
            expect(str[1]).to match(/^3400/)
            expect(str.last).to match(/^201/)
          end
        end
      end
      context '#home_timeline' do 
        describe 'maxes out at 800 tweets received' do
          before do
            q_opts = {:count => '200', :include_entities => 'false'}
            (0..17).each do |t|
              y = 200 * (17 - t)
              q_opts[:max_id] = y if t > 0
              x = y - 199
              stub_get('/1.1/statuses/home_timeline.json').with(:query => q_opts).to_return(:body => stubby_tweets(x, y), :headers => {:content_type => 'application/json; charset=utf-8'})
            end
          end
          it 'outputs 801 lines' do
            @cli.timeline
            str = $stdout.string.split("\n")
            expect(str.count).to eq 801
            expect(str[1]).to match(/^3400/)
            expect(str.last).to match(/^2601/)
          end
        end
      end
    end
  end
end
