# encoding: utf-8
require 'helper'
describe 'Searching Twitter with trim_user: false' do

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
      T::RCFile.instance.path = fixture_path + '/.trc'
      @search = T::Search.new
      @search.options = @search.options.merge('color' => 'always', 'show_user' => true, 'long' => false)
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


    describe '#all' do
      before do
        stub_get('/1.1/search/tweets.json').with(:query => {q: "#ddj", count: '100', include_entities: 'false', trim_user: 'false'}).to_return(:body => fixture('search_tweets_untrimmed.json'))
      end

      it 'requests the correct resource' do
        @search.all('#ddj')
        expect(a_get('/1.1/search/tweets.json').with(:query => {q: "#ddj", count: '100', include_entities: 'false', trim_user: 'false'} )).to have_been_made
      end

      it 'defaults to --long format, even if long is set to false' do
        @search.all('#ddj')
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name       Text                     ...
423221222831185920  Jan 14 14:32  @mirkolorenz      RT @storywithdata: If you...
423220530905612288  Jan 14 14:30  @hgrosado         .@albertocairo "La ética ...
423220045909471233  Jan 14 14:28  @mirkolorenz      @KarrieKehoe did you chec...
423215132705955840  Jan 14 14:08  @mirkolorenz      @krees: Just for the cont...
423213770416979969  Jan 14 14:03  @digiphile        $$ for "solutions journal...
423213484189302784  Jan 14 14:02  @mirkolorenz      @KarrieKehoe did you see ...
423212851277230080  Jan 14 13:59  @mirkolorenz      @davilalu: Leaving for #d...
423212369108422656  Jan 14 13:57  @mirkolorenz      Data-driven marketing: Sl...
423210209591721984  Jan 14 13:49  @BigPupazzoVerde  RT @Carlapedret: Les vari...
423206858245955584  Jan 14 13:35  @plusepsilon      RT @EdwardTufte: Data/Des...
423205504614010881  Jan 14 13:30  @karstenhufer     Auch das ist #Datenjourna...
423203587771363328  Jan 14 13:22  @UlrikWillemoes   RT @EdwardTufte: Data/Des...
423202467388456960  Jan 14 13:18  @KarrieKehoe      Any recommendations on wh...
423200461064134656  Jan 14 13:10  @JulieMilland     RT @EdwardTufte: Data/Des...
423199147328823296  Jan 14 13:05  @Rubicon_BI       RT @Carlapedret: Les vari...
423197881819217920  Jan 14 13:00  @ruppchristian    RT @rupprECHT: BBC signs ...
423194870484725760  Jan 14 12:48  @alexiamadd       RT @EdwardTufte: Data/Des...
423193972123893760  Jan 14 12:44  @RechercheLab     RT @datenjournalist: Konf...
423191923864530944  Jan 14 12:36  @oncloudhcm       RT @EdwardTufte: Data/Des...
423190924726788096  Jan 14 12:32  @jonathanpb       RT @EdwardTufte: Data/Des...
        eos
      end

      context '--csv' do
        before do
          @search.options = @search.options.merge('csv' => true)
        end

        it 'should output to CSV with additional headers' do
          @search.all('#ddj')
          expect($stdout.string.split("\n")[0..1].join("\n")).to eq %q{ID,Posted at,Screen name,Text,User ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Name,Verified,Protected,Bio,Location,URL
423221222831185920,2014-01-14 22:32:57 +0000,mirkolorenz,RT @storywithdata: If you ever find yourself wanting to use a donut chart: please change your mind. http://t.co/Cb5ZaDoSii #dataviz #ddj,42221155,2009-05-24 14:43:15 +0000,2014-01-14 22:32:57 +0000,4277,1613,243,808,1941,Mirko Lorenz,false,false,Journalism++ | Cologne chapter,"Cologne, Germany",http://t.co/xc3T5K1C5Y}
        end

      end
    end
  end

end