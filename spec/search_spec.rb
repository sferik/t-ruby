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
    @search.options = @search.options.merge("color" => "always")
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
      stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "20"}).to_return(:body => fixture("search.json"))
    end
    it "requests the correct resource" do
      @search.all("twitter")
      expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "20"})).to have_been_made
    end
    it "has the correct output" do
      @search.all("twitter")
      expect($stdout.string).to eq <<-eos

   @saintsday998
   Murray Energy Corp. Obama Reelection, Announces Layoffs http://t.co/D1OPtKnw 
   via @HuffPostBiz MAYBE his workers can do something for him ?

   @thlyons
   Obama Administration Extends Deadline For State Exchanges - Kaiser Health 
   News http://t.co/dyaM4jF1

   @justmaryse
   Fox News accidentally insults the intelligence of every Mitt Romney voter in 
   the country. http://t.co/sQbt16RF via @HappyPlace #awkward

   @BlueTrooth
   RT @AntiWacko: It's hilarious to watch the Conservatives getting hysterical 
   about Pres Obama's re-election. #p2 #tcot

   @robbiegleeson
   RT @Revolution_IRL: RT if you agree its insane that tubridy gets paid more 
   than obama #LateLate

   @melinwy
   RT @Kristina_x_x: GOP enthusiasm, was higher, registration was higher, crowds 
   larger, intensity larger. yet Obama won. Hmmmm @mittromney

   @WANT1DTOFOLLOWU
   RT @LoveYungCotta: Romney talks about Obama. Obama talks about the nation. 
   Romney says "I." Obama says "We." Pay attention to the small things. 
   #voteobama

   @bodysouls
   @RealJonLovitz Did u see this? Barbara Teixeira@BarbArn

   OBAMA REELECTION TRIGGERS MASSIVE LAYOFFS ACROSS AMERICA http://t.co/kfuILrmE 
   …

   @tinasebring
   RT @ken24xavier: YES OBAMA we really really believe CIA Director Petraeus 
   Resigns... over extramarital affair? OH LOOK cows flying over the Moon

   @OD_Worrell
   RT @AP: White House says #Obama will travel to New York on Thursday to view 
   recovery efforts from Superstorm Sandy: http://t.co/MCS6MceM

   @LathamChalaGrp
   Obama Hangs Tough on the Fiscal Cliff His speech increases the likelihood 
   that negotiations will drag on well into 2013

   @sesto09
   La lettera di Obama sui genitori gay http://t.co/dmFkfbgG

   @NickLoveSlayer
   RT @NewsMCyrus: Despues De que gano Obama las elecciones, empezo a sonar 
   Party In The U.S.A de Miley Cyrus en la casa blanca

   @Ch_pavon17
   RT @PrincipeWilli: -Hoy me desperte bien electo. -Jajaja, pinche Obama, eres 
   un desmadre..

   @weeki1
   RT @jjauthor: #Navy names newest ship - USS Barack Obama #GoNavy 
   http://t.co/F6PGNTjX

   @LugosLove
   Wow, Obama Started Crying While He Was Giving A Speech To His Campaign Staff

   @jbrons
   RT @dwiskus: Obama played OHIO to win 26-24. http://t.co/CEW5XMtc

   @Moondances_
   RT @_pedropenna: OBAMA teve o tweet mais retweetado da historia ai e obvio 
   que as fãs do justin vão falar: VAMOS BATER ESSE 
   RECORDDDDDDDDDDDDDDDDDDDDDDDDDDDD

   @matthew_austin4
   No, I will not shut up. I don't like Obama. I will continue to tweet my mind.

   @FreebirdForever
   RT @Bobprintdoc: @vickikellar vicki your overdrawn on your Obama bashing 
   account please insert 16,000,000,000,000 dollars or whatever the national 
   debt is

   @_WHOOPdefckindo
   RT @RiIeyJokess: ME: who you voting for? WHITE PEOPLE: I rather not discuss 
   that with you.

   ME: who you voting for?? BLACK PEOPLE: TF U MEAN?? OBAMA N*GGA!

   @nikkipjah
   #Obama's track record with #HumanRights http://t.co/fTrjJHtB

   @pandphomemades
   RT @JewPublican: Think about it. All of big Hollywood supported obama. 
   Everything we see now is pretty much out of movies. Truth is Stranger than 
   Fiction!

   @Vita__Nova
   Bunda rus-israil ittifakının etkisi çok büyük. Obama ilk ziyaretini 
   Türkiye'ye yapmayacak. Yoksa hedef tahtasında olur.

   @tv6tnt
   White House says Obama will travel to New York on Thursday to view recovery 
   efforts from Superstorm Sandy

   @ricardo126234
   @Jacquie0415 @gregwhoward obama is not a muslim. Whatever fox news channel 
   you got that from was lying to you.

   @LifesaBishh
   RT @SomeoneBelow: The person below is complaining about Obama.

   @I_Fuk_Wid_OBAMA
   :) #Pixect http://t.co/jZxz8JeC

   @llParadisell
   Why Libya Cover-Up: Obama Was Arming Al Qaeda & Islamists 
   http://t.co/erdKx6HD

   @naiburnwoood
   RT @StephenAtHome: I still can't believe Obama won. I will do everything in 
   my power to make sure this is his LAST term as president!

   @Neo_Sweetness
   RT @5oodaysofautumn: #Obama crying choked me up NEVER SEEN A PRES DO THAT. U 
   CAN TELL HIS INTENTIONS ARE IN THE RIGHT PLACE TO LEAD http://t.co/oez0ySOl

   @vcAraceli
   RT @jusxy: Obama what's my name? Obama what's my name? OBAMA what's my name? 
   what's my name? .... #OBALIEN what's my name

   @notsoslimshadys
   RT @harrynstuff: I bet one day stalker sarah stalks her way into the white 
   house she'll just take a picture from Obama's bedroom

   @ThinksLogical
   RT @dlb703: The difference between Romney and Obama supporters? Romney's look 
   like they just got out of church. Obama's look like they're out on parole.

   @pabloirossi
   Obama, ante el precipicio fiscal: "Tengo mi boligrafo listo para firmar" 
   http://t.co/m5Q6O0lq via @expansioncom

   @mermaid6590
   @LeslieMHooper I think Obama and Chris Christie are having an affair! LMAO!!!

   @n_mariee3
   RT @SAMhOes: Lmao #Obama http://t.co/uxLqQ8zq

   @soso2583
   RT @20Minutes: Pour Obama, les Americains les plus riches doivent payer plus 
   d'impôts http://t.co/PiZXc0Ty

   @desertkev
   @k_m_allan I'm more about #Obama being banished.

   @blakecallaway
   yo why did obama have to win

   @AlondraMiaa
   RT @FaithOn1D: "Las hijas de Obama conocieron a los Jonas, a Justin Bieber y 
   ahora conocerán a One Direction" @BarackObama ¡HOLA PAPIIIIIIIIIII!

   @4iHD
   Szef CIA zrezygnował przez romans. Obama "trzyma kciuki za niego i żonę" 
   http://t.co/XiPB0RSW

   @fcukjessi
   RT @JosieNelson7: Obama yeehaw http://t.co/DJxtDlAk

   @Evilazio
   Obama "decepciona" mercados. Idiotice! Os mercados estão sendo movidos pela 
   China, que retoma crescimento. So os ricos estão preocupados.

   @carolynedgar
   @GoAngelo let's just speculate that Petraeus was having an affair WITH Obama 
   and they conspired during pillow talk to cover up Benghazi.

   @bob_mor
   RT @NoticiasCaracol: Obama acepta renuncia del director de la CIA, que deja 
   el cargo tras reconocer que tuvo relacion extramatrimonial 
   http://t.co/uU6j0p7q

   @NotBarack
   FEMA Failed/Obama Hailed #Sandy #tcot #obama

   @georgiaokeeffex
   Obama

   @LLW83
   RT @TheDailyEdge: Obama has a mandate to raise taxes on top 2% to Clinton-era 
   levels. To stop him, the "anti-tax" GOP will raise taxes on 100% of us 
   #insanity

   @aylin_arellanoo
   RT @lupiss14: - Ya viste que gano el PRI en EU? -¿El PRI? - Si, el PRIeto de 
   Obama.

   @ASyrupp
   @realDonaldTrump hey idiot-obama won pop. vote&electoral. What's the baby 
   with the toupee crying bout? U Deleted revolution tweet? Coward

   @JConason
   RT @HuffingtonPost: CEO who forced workers to attend Romney rally now 
   promises layoffs http://t.co/nZ15MB9x

   @hwain_96
   RT @_Ken_barlow_: Cameron: "I look forward to working with Obama for the next 
   four years." 2 years Dave, 2 years.

   @shetrulylovedya
   ate o obama e a familia dançam o gangnam style...

   @r9mcgon
   RT @Mike_hugs: Nixon +Kissinger tested the theory that if you bomb a country 
   and risk no U.S. lives the anti-war movement fizzles. Obama proved it 
   correct.

   @skew11
   RT @RepJeffDuncan: 102 miners laid off in Utah as a direct result of 
   President Obama's policies. http://t.co/35lZ7Zmv

   @ayyuradita
   Congratulation for barack obama [pic] — http://t.co/OJy8DE6T

   @homeoffice_biz
   Hugo Chavez Offers Obama Some Advice: Fresh off his own reelection, 
   Venezuelan President Hugo Chavez has a stron... http://t.co/HD7dUzVg

   @donthebear
   Bone head and Google eys would not answer the POTUS phone call! 
   http://t.co/rra6QAiw

   @Imercuryinfo
   9% Inflation, Obama Care, fewer rights in our socialist future even if Romney 
   had won. http://t.co/0ZAO8Xv6

   @lege_atque_lacr
   Obama holds firm to tax hikes (That is his DNA) http://t.co/TgRk59ir via 
   @foxbusiness

   @vldpopov
   So, selling Obama is similar to selling yoghurts - Secret Data Crunchers Who 
   Helped Obama Win http://t.co/dt5w3xuE via @TIMEPolitics

   @DanieMilli_anne
   then they really wanna argue about it..like what you mad at? Obama is 
   president don't waste your emotion.

   @Says_The_King
   I got me an Obama momma. She always be puttin some free money in my account

   @Tatts_N_Dreads
   RT @CNNMoney: Gun sales are up after Obama's reelection, driven by fears of 
   tighter regulation, especially for assault weapons. http://t.co/KEOgWSG9

   @mensadude
   Ron Paul: Election shows U.S. 'far gone' http://t.co/CQoYn2iQ #tcot #teaparty 
   #ronpaul #unemployment #deficit #jobs #gop #USHOUSE #OBAMA

   @IKrUsHiNsKi
   @britney_brinae lol move to Canada if u like Obama sorry this countries not 
   socialist. Ignorance at its finest.

   @mgracer514
   @SpeakerBoehner Do NOT give in To Obama John!!! He and Harry Reid KNOW 
   raising taxes on the job creators will not create more tax revenue!!!

   @leenpaape
   RT @TheEconomist: Video: Barack Obama looks ahead to four more years and 
   China reveals its next leaders http://t.co/qpho3KlS

   @Timmermanscm
   RT @__Wieke__: Net als in Nederland, toch?! @NOS: Obama: rijken moeten meer 
   belasting betalen http://t.co/gDEN4urK"

   @ColeMurdock24
   People who like the snow also voted for Obama.

   @tbest
   Awesome. "@daringfireball: 'Obama Played OHIO to Win 26-24': 
   http://t.co/D2eP8EKy"

   @ibtxhis_SaMone
   RT @WeirdFact: President Obama was known to be heavy marijuana smoker in his 
   teen and college days. His nickname used to be "Barack Oganja".

   @alejandrita_lm
   RT @VaneEscobarR: Las hijas de Obama conocieron a los Jonas, a Justin y 
   consiguieron primera fila para ver a One Direction ¡OBAMA ADOPTAME!

   @stewie64
   RT @DanRiehl: How does this work, anyway? Does the media let Obama vet it's 
   questions for everyone?

   @Evilpa
   RT @AACONS: How does Obama's plan to close 1.6M acres of fed land to shale 
   development fit in his plan to create jobs? http://t.co/FOYjcxP6 #tcot #acon

   @DayKadence
   RT @Frances_D: Pundit Press: What Luck! Obama Won Dozens of Cleveland 
   Districts... http://t.co/xwWpcpAV

   @Mel_DaOne_
   Nah, that ain't right RT @julieisthatcool: I'll fuck Obama wife

   @Aslans_Girl
   Pundit Press: What Luck! Obama Won Dozens of Cleveland Districts... 
   http://t.co/aCMvGeUr

   @crazyinms
   RT @Clickman8: I'm sure PUTIN, HUGO,CASTRO & AhMADinejad are thrilled over 
   the outcome of the Election! OBAMA fits quite nicely in2 their Circle of 
   Friends

   @JaeGun_LaoLin
   RT @Kennyment: POURQUOI VOUS INVENTEZ DES PAIRINGS COMME ÇA ? LE PIRE QUE 
   J'AI VU DE TOUTE MA VIE C'ETAIT OBATAE. OBAMA/TAEMIN.

   @borealizz
   RT @utaustinliberal: Jake Tapper demands Carney release a tick-tock of where 
   Pres. Obama was during the Benghazi attack. Shorter Carney: Who the f**k are 
   you?

   @justessheather
   My uncle posted a picture on facebook of seagulls on a shore and said it was 
   "Obama's supporters waiting for their handouts" lmfao I can't.

   @maxD_ooUt
   "@JennaNanci: My family is fucked because Obama is the president." Join the 
   club

   @KacyleneS
   RT @ArsheanaLaNesha: White gyrls yall fucking black nigghas so stop riding 
   OBAMA DICK DAMN

   @Imercuryinfo
   I uploaded a @YouTube video http://t.co/BgQkRT5u 9% Inflation, Obama Care, 
   fewer rights in our socialist future even if Romney had

   @MuslimGeezer
   Aung San Suu Kyi initially opposed Obama's Burma trip http://t.co/rntYv65C

   @MDiPasquale1999
   @MarciaCM1 @royparrish of course Obama accepted his resignation because he 
   wrote his "resignation."

   @TigerBaby84
   RT @BreitbartNews: Obama: No Deal Without Tax Hikes: The lines are now set 
   for the battle over the fiscal cliff. The fiscal cliff, ... 
   http://t.co/YDHgzwFE

   @CriticalMassTX
   RT @thinkprogress: The 6 best overreactions to Obama's win. watch Glenn 
   Beck's rant. spooky shit http://t.co/sZfQkkLd via @ARStrasser #icymi

   @cobe001001
   RT @whitehouse: President Obama: "I'm committed to solving our fiscal 
   challenges. But I refuse to accept any approach that isn't balanced."

   @MeganPanatier
   City of Obama to invite Obama to Japan - The Tokyo Times http://t.co/1SwafGOM 
   via @TheTokyoTimes

   @Katie_janca
   RT @140elect: Hillary Clinton has said for years she wont serve in Obama's 
   second term. Now if/when she resigns #Benghazi conspiracists will go crazy.

   @Linapooh1
   Sumbody had to do it!! The Obama Car! http://t.co/NLSrOT4A

   @cinrui
   RT @SeanKCarter: Oliver Stone "I find Obama scary!" So do we Mr. Stone, so do 
   we... http://t.co/39YIdQkq #tcot

   @nthowa2
   Obama in a cover up folks! Are we this dumb? CIA Director Petraeus Resigns 
   Over 'Affair' http://t.co/ZKu297Gz via @BreitbartNews

   @dirtyvic_1
   @glennbeck @seahannity Commander Fitzpatrick Files Treason Charges Against 
   Barack Obama #teaparty #UT #Election http://t.co/T9GHyUZ4

   @SteveCaruso
   Great election background....http://t.co/HwdVs40N

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.all("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
267024754278539266,2012-11-09 22:03:57 +0000,saintsday998,"Murray Energy Corp. Obama Reelection, Announces Layoffs http://t.co/D1OPtKnw via @HuffPostBiz MAYBE  his workers can do something for him ?"
267024753326448640,2012-11-09 22:03:56 +0000,thlyons,Obama Administration Extends Deadline For State Exchanges - Kaiser Health News http://t.co/dyaM4jF1
267024753292869634,2012-11-09 22:03:56 +0000,justmaryse,Fox News accidentally insults the intelligence of every Mitt Romney voter in the country. http://t.co/sQbt16RF via @HappyPlace #awkward
267024751854252033,2012-11-09 22:03:56 +0000,BlueTrooth,RT @AntiWacko: It's hilarious to watch the Conservatives getting hysterical about Pres Obama's re-election. #p2 #tcot
267024751657115648,2012-11-09 22:03:56 +0000,robbiegleeson,RT @Revolution_IRL: RT if you agree its insane that tubridy gets paid more than obama #LateLate
267024751619350528,2012-11-09 22:03:56 +0000,melinwy,"RT @Kristina_x_x: GOP enthusiasm, was higher, registration was higher, crowds larger, intensity larger. yet Obama won. Hmmmm @mittromney"
267024751585808384,2012-11-09 22:03:56 +0000,WANT1DTOFOLLOWU,"RT @LoveYungCotta: Romney talks about Obama. Obama talks about the nation. Romney says ""I."" Obama says ""We."" Pay attention to the small things. #voteobama"
267024751321575424,2012-11-09 22:03:56 +0000,bodysouls,"@RealJonLovitz  Did u see this? Barbara Teixeira@BarbArn

 OBAMA REELECTION TRIGGERS MASSIVE LAYOFFS ACROSS AMERICA http://t.co/kfuILrmE …"
267024750109396993,2012-11-09 22:03:56 +0000,tinasebring,RT @ken24xavier: YES OBAMA we really really believe CIA Director Petraeus Resigns... over extramarital affair? OH LOOK cows flying over the Moon
267024749979373568,2012-11-09 22:03:56 +0000,OD_Worrell,RT @AP: White House says #Obama will travel to New York on Thursday to view recovery efforts from Superstorm Sandy: http://t.co/MCS6MceM
267024749622865921,2012-11-09 22:03:56 +0000,LathamChalaGrp,Obama Hangs Tough on the Fiscal Cliff His speech increases the likelihood that negotiations will drag on well into 2013
267024749501218817,2012-11-09 22:03:56 +0000,sesto09,La lettera di Obama sui genitori gay http://t.co/dmFkfbgG
267024748779819009,2012-11-09 22:03:55 +0000,NickLoveSlayer,"RT @NewsMCyrus: Despues De que gano Obama las elecciones, empezo a sonar Party In The U.S.A de Miley Cyrus en la casa blanca"
267024748536541185,2012-11-09 22:03:55 +0000,Ch_pavon17,"RT @PrincipeWilli: -Hoy me desperte bien electo.
-Jajaja, pinche Obama, eres un desmadre.."
267024746821058560,2012-11-09 22:03:55 +0000,weeki1,RT @jjauthor: #Navy names newest ship - USS Barack Obama #GoNavy http://t.co/F6PGNTjX
267024746724605952,2012-11-09 22:03:55 +0000,LugosLove,"Wow, Obama Started Crying While He Was Giving A Speech To His Campaign Staff"
267024746389061633,2012-11-09 22:03:55 +0000,jbrons,RT @dwiskus: Obama played OHIO to win 26-24. http://t.co/CEW5XMtc
267024746372268032,2012-11-09 22:03:55 +0000,Moondances_,RT @_pedropenna: OBAMA teve o tweet mais retweetado da historia ai e obvio que as fãs do justin vão falar: VAMOS BATER ESSE RECORDDDDDDDDDDDDDDDDDDDDDDDDDDDD
267024745642463233,2012-11-09 22:03:55 +0000,matthew_austin4,"No, I will not shut up. I don't like Obama. I will continue to tweet my mind."
267024745546014720,2012-11-09 22:03:55 +0000,FreebirdForever,"RT @Bobprintdoc: @vickikellar vicki your overdrawn on your Obama bashing account please insert 16,000,000,000,000 dollars or whatever the national debt is"
267024744673587201,2012-11-09 22:03:54 +0000,_WHOOPdefckindo,"RT @RiIeyJokess: ME: who you voting for?
WHITE PEOPLE: I rather not discuss that with you.

ME: who you voting for??
BLACK PEOPLE: TF U MEAN?? OBAMA N*GGA!"
267024743629209601,2012-11-09 22:03:54 +0000,nikkipjah,"#Obama's track record with #HumanRights
http://t.co/fTrjJHtB"
267024743323033600,2012-11-09 22:03:54 +0000,pandphomemades,RT @JewPublican: Think about it. All of big Hollywood supported obama. Everything we see now is pretty much out of movies. Truth is Stranger than Fiction!
267024742899412992,2012-11-09 22:03:54 +0000,Vita__Nova,Bunda rus-israil ittifakının etkisi çok büyük. Obama ilk ziyaretini Türkiye'ye yapmayacak.  Yoksa hedef tahtasında olur.
267024742295416832,2012-11-09 22:03:54 +0000,tv6tnt,White House says Obama will travel to New York on Thursday to view recovery efforts from Superstorm Sandy
267024742257680386,2012-11-09 22:03:54 +0000,ricardo126234,@Jacquie0415 @gregwhoward obama is not a muslim. Whatever fox news channel you got that from was lying to you.
267024741381074944,2012-11-09 22:03:54 +0000,LifesaBishh,RT @SomeoneBelow: The person below is complaining about Obama.
267024740810637313,2012-11-09 22:03:54 +0000,I_Fuk_Wid_OBAMA,:) #Pixect http://t.co/jZxz8JeC
267024740760289280,2012-11-09 22:03:53 +0000,llParadisell,"Why Libya Cover-Up: Obama Was Arming Al Qaeda & Islamists
http://t.co/erdKx6HD"
267024739627839488,2012-11-09 22:03:53 +0000,naiburnwoood,RT @StephenAtHome: I still can't believe Obama won. I will do everything in my power to make sure this is his LAST term as president!
267024738927394816,2012-11-09 22:03:53 +0000,Neo_Sweetness,RT @5oodaysofautumn: #Obama crying choked me up NEVER SEEN A PRES DO THAT. U CAN TELL HIS INTENTIONS ARE  IN THE RIGHT PLACE TO LEAD http://t.co/oez0ySOl
267024738906431490,2012-11-09 22:03:53 +0000,vcAraceli,RT @jusxy: Obama what's my name? Obama what's my name? OBAMA what's my name? what's my name? .... #OBALIEN what's my name
267024738575065089,2012-11-09 22:03:53 +0000,notsoslimshadys,RT @harrynstuff: I bet one day stalker sarah stalks her way into the white house she'll just take a picture from Obama's bedroom
267024738478600192,2012-11-09 22:03:53 +0000,ThinksLogical,RT @dlb703: The difference between Romney and Obama supporters? Romney's look like they just got out of church. Obama's look like they're out on parole.
267024737937547264,2012-11-09 22:03:53 +0000,pabloirossi,"Obama, ante el precipicio fiscal: ""Tengo mi boligrafo listo para firmar"" http://t.co/m5Q6O0lq via @expansioncom"
267024737794945024,2012-11-09 22:03:53 +0000,mermaid6590,@LeslieMHooper I think Obama and Chris Christie are having an affair!  LMAO!!!
267024737706840064,2012-11-09 22:03:53 +0000,n_mariee3,RT @SAMhOes: Lmao #Obama http://t.co/uxLqQ8zq
267024737354534912,2012-11-09 22:03:53 +0000,soso2583,"RT @20Minutes: Pour Obama, les Americains les plus riches doivent payer plus d'impôts http://t.co/PiZXc0Ty"
267024736968667136,2012-11-09 22:03:53 +0000,desertkev,@k_m_allan I'm more about #Obama being banished.
267024736373063680,2012-11-09 22:03:52 +0000,blakecallaway,yo why did obama have to win
267024736108818432,2012-11-09 22:03:52 +0000,AlondraMiaa,"RT @FaithOn1D: ""Las hijas de Obama conocieron a los Jonas, a Justin Bieber y ahora conocerán a One Direction"" @BarackObama ¡HOLA PAPIIIIIIIIIII!"
267024735878119424,2012-11-09 22:03:52 +0000,4iHD,"Szef CIA zrezygnował przez romans. Obama ""trzyma kciuki za niego i żonę"" http://t.co/XiPB0RSW"
267024735450324993,2012-11-09 22:03:52 +0000,fcukjessi,RT @JosieNelson7: Obama yeehaw http://t.co/DJxtDlAk
267024735156703232,2012-11-09 22:03:52 +0000,Evilazio,"Obama ""decepciona"" mercados. Idiotice!  Os mercados estão sendo movidos pela China, que retoma  crescimento. So os ricos estão preocupados."
267024734628233218,2012-11-09 22:03:52 +0000,carolynedgar,@GoAngelo let's just speculate that Petraeus was having an affair WITH Obama and they conspired during pillow talk to cover up Benghazi.
267024734481440769,2012-11-09 22:03:52 +0000,bob_mor,"RT @NoticiasCaracol: Obama acepta renuncia del director de la CIA, que deja el cargo tras reconocer que tuvo relacion extramatrimonial http://t.co/uU6j0p7q"
267024734464651264,2012-11-09 22:03:52 +0000,NotBarack,FEMA Failed/Obama Hailed #Sandy #tcot #obama
267024733319598080,2012-11-09 22:03:52 +0000,georgiaokeeffex,Obama
267024733189582849,2012-11-09 22:03:52 +0000,LLW83,"RT @TheDailyEdge: Obama has a mandate to raise taxes on top 2% to Clinton-era levels. To stop him, the ""anti-tax"" GOP will raise taxes on 100% of us #insanity"
267024733067943936,2012-11-09 22:03:52 +0000,aylin_arellanoo,"RT @lupiss14: - Ya viste que gano el PRI en EU?    -¿El PRI?    - Si, el PRIeto de Obama."
267024732984053761,2012-11-09 22:03:52 +0000,ASyrupp,@realDonaldTrump hey idiot-obama won pop. vote&electoral. What's the baby with the toupee crying bout? U Deleted revolution tweet? Coward
267024732984053760,2012-11-09 22:03:52 +0000,JConason,RT @HuffingtonPost: CEO who forced workers to attend Romney rally now promises layoffs http://t.co/nZ15MB9x
267024732812095488,2012-11-09 22:03:52 +0000,hwain_96,"RT @_Ken_barlow_: Cameron: ""I look forward to working with Obama for the next four years."" 2 years Dave, 2 years."
267024731352481792,2012-11-09 22:03:51 +0000,shetrulylovedya,ate o obama e a familia dançam o gangnam style...
267024731193110528,2012-11-09 22:03:51 +0000,r9mcgon,RT @Mike_hugs: Nixon +Kissinger tested the theory that if you bomb a country and risk no U.S. lives the anti-war movement fizzles. Obama proved it correct.
267024729980928000,2012-11-09 22:03:51 +0000,skew11,RT @RepJeffDuncan: 102 miners laid off in Utah as a direct result of President Obama's policies. http://t.co/35lZ7Zmv
267024729972568065,2012-11-09 22:03:51 +0000,ayyuradita,Congratulation for barack obama [pic] — http://t.co/OJy8DE6T
267024729741877249,2012-11-09 22:03:51 +0000,homeoffice_biz,"Hugo Chavez Offers Obama Some Advice: Fresh off his own reelection, Venezuelan President Hugo Chavez has a stron... http://t.co/HD7dUzVg"
267024729708298240,2012-11-09 22:03:51 +0000,donthebear,Bone head and Google eys would not answer the POTUS phone call! http://t.co/rra6QAiw
267024729527971841,2012-11-09 22:03:51 +0000,Imercuryinfo,"9% Inflation, Obama Care, fewer rights in our socialist future even if Romney had won. http://t.co/0ZAO8Xv6"
267024728898801664,2012-11-09 22:03:51 +0000,lege_atque_lacr,Obama holds firm to tax hikes (That is his DNA)  http://t.co/TgRk59ir via @foxbusiness
267024728403886080,2012-11-09 22:03:50 +0000,vldpopov,"So, selling Obama is  similar to selling yoghurts - Secret Data Crunchers Who Helped Obama Win http://t.co/dt5w3xuE via @TIMEPolitics"
267024727971856384,2012-11-09 22:03:50 +0000,DanieMilli_anne,then they really wanna argue about it..like what you mad at? Obama is president don't waste your emotion.
267024726549999616,2012-11-09 22:03:50 +0000,Says_The_King,I got me an Obama momma. She always be puttin some free money in my account
267024726214463488,2012-11-09 22:03:50 +0000,Tatts_N_Dreads,"RT @CNNMoney: Gun sales are up after Obama's reelection, driven by fears of tighter regulation, especially for assault weapons. http://t.co/KEOgWSG9"
267024725941817345,2012-11-09 22:03:50 +0000,mensadude,"Ron Paul: Election shows U.S. 'far gone' 
 http://t.co/CQoYn2iQ #tcot #teaparty #ronpaul #unemployment #deficit #jobs #gop #USHOUSE #OBAMA"
267024725505622016,2012-11-09 22:03:50 +0000,IKrUsHiNsKi,@britney_brinae lol move to Canada if u like Obama sorry this countries not socialist. Ignorance at its finest.
267024724817760256,2012-11-09 22:03:50 +0000,mgracer514,@SpeakerBoehner Do NOT give in To Obama John!!! He and Harry Reid KNOW raising taxes on the job creators will not create more tax revenue!!!
267024724792590336,2012-11-09 22:03:50 +0000,leenpaape,RT @TheEconomist: Video: Barack Obama looks ahead to four more years and China reveals its next leaders http://t.co/qpho3KlS
267024724574474241,2012-11-09 22:03:50 +0000,Timmermanscm,"RT @__Wieke__: Net als in Nederland, toch?! @NOS: Obama: rijken moeten meer belasting betalen http://t.co/gDEN4urK"""
267024723769176064,2012-11-09 22:03:49 +0000,ColeMurdock24,People who like the snow also voted for Obama.
267024723211333632,2012-11-09 22:03:49 +0000,tbest,"Awesome. ""@daringfireball: 'Obama Played OHIO to Win 26-24': http://t.co/D2eP8EKy"""
267024723005808640,2012-11-09 22:03:49 +0000,ibtxhis_SaMone,"RT @WeirdFact: President Obama was known to be heavy marijuana smoker in his teen and college days. His nickname used to be ""Barack Oganja""."
267024722540244992,2012-11-09 22:03:49 +0000,alejandrita_lm,"RT @VaneEscobarR: Las hijas de Obama conocieron a los Jonas, a Justin y consiguieron primera fila para ver a One Direction ¡OBAMA ADOPTAME!"
267024721495879680,2012-11-09 22:03:49 +0000,stewie64,"RT @DanRiehl: How does this work, anyway? Does the media let Obama vet it's questions for everyone?"
267024721315504128,2012-11-09 22:03:49 +0000,Evilpa,RT @AACONS: How does Obama's plan to close 1.6M acres of fed land to shale development fit in his plan to create jobs? http://t.co/FOYjcxP6 #tcot #acon
267024720321458176,2012-11-09 22:03:49 +0000,DayKadence,RT @Frances_D: Pundit Press: What Luck! Obama Won Dozens of Cleveland Districts... http://t.co/xwWpcpAV
267024719470002176,2012-11-09 22:03:48 +0000,Mel_DaOne_,"Nah, that ain't right RT @julieisthatcool: I'll fuck Obama wife"
267024719272878080,2012-11-09 22:03:48 +0000,Aslans_Girl,Pundit Press: What Luck! Obama Won Dozens of Cleveland Districts... http://t.co/aCMvGeUr
267024719138660352,2012-11-09 22:03:48 +0000,crazyinms,"RT @Clickman8: I'm sure PUTIN, HUGO,CASTRO & AhMADinejad are thrilled over the outcome of the Election! OBAMA fits quite nicely in2 their Circle of Friends"
267024717301555200,2012-11-09 22:03:48 +0000,JaeGun_LaoLin,RT @Kennyment: POURQUOI VOUS INVENTEZ DES PAIRINGS COMME ÇA ? LE PIRE QUE J'AI VU DE TOUTE MA VIE C'ETAIT OBATAE. OBAMA/TAEMIN.
267024717028941824,2012-11-09 22:03:48 +0000,borealizz,RT @utaustinliberal: Jake Tapper demands Carney release a tick-tock of where Pres. Obama was during the Benghazi attack. Shorter Carney: Who the f**k are you?
267024716429139968,2012-11-09 22:03:48 +0000,justessheather,"My uncle posted a picture on facebook of seagulls on a shore and said it was ""Obama's supporters waiting for their handouts"" lmfao I can't."
267024716362031105,2012-11-09 22:03:48 +0000,maxD_ooUt,"""@JennaNanci: My family is fucked because Obama is the president."" Join the club"
267024716181696512,2012-11-09 22:03:48 +0000,KacyleneS,RT @ArsheanaLaNesha: White gyrls yall fucking black nigghas so stop riding OBAMA DICK DAMN
267024714717884416,2012-11-09 22:03:47 +0000,Imercuryinfo,"I uploaded a @YouTube video http://t.co/BgQkRT5u 9% Inflation, Obama Care, fewer rights in our socialist future even if Romney had"
267024714566885376,2012-11-09 22:03:47 +0000,MuslimGeezer,Aung San Suu Kyi initially opposed Obama's Burma trip http://t.co/rntYv65C
267024714407493632,2012-11-09 22:03:47 +0000,MDiPasquale1999,"@MarciaCM1 @royparrish of course Obama accepted his resignation because he wrote his ""resignation."""
267024713979662336,2012-11-09 22:03:47 +0000,TigerBaby84,"RT @BreitbartNews: Obama: No Deal Without Tax Hikes: The lines are now set for the battle over the fiscal cliff. The fiscal cliff, ... http://t.co/YDHgzwFE"
267024713883193344,2012-11-09 22:03:47 +0000,CriticalMassTX,RT @thinkprogress: The 6 best overreactions to Obama's win. watch Glenn Beck's rant. spooky shit http://t.co/sZfQkkLd via @ARStrasser #icymi
267024713161781250,2012-11-09 22:03:47 +0000,cobe001001,"RT @whitehouse: President Obama: ""I'm committed to solving our fiscal challenges. But I refuse to accept any approach that isn't balanced."""
267024713157578752,2012-11-09 22:03:47 +0000,MeganPanatier,City of Obama to invite Obama to Japan - The Tokyo Times http://t.co/1SwafGOM via @TheTokyoTimes
267024712977219584,2012-11-09 22:03:47 +0000,Katie_janca,RT @140elect: Hillary Clinton has said for years she wont serve in Obama's second term. Now if/when she resigns #Benghazi conspiracists will go crazy.
267024712549400576,2012-11-09 22:03:47 +0000,Linapooh1,Sumbody had to do it!! The Obama Car! http://t.co/NLSrOT4A
267024712264212480,2012-11-09 22:03:47 +0000,cinrui,"RT @SeanKCarter: Oliver Stone ""I find Obama scary!"" So do we Mr. Stone, so do we... http://t.co/39YIdQkq #tcot"
267024712247435264,2012-11-09 22:03:47 +0000,nthowa2,Obama in a cover up folks! Are we this dumb?       CIA Director Petraeus Resigns Over 'Affair' http://t.co/ZKu297Gz via @BreitbartNews
267024711932858368,2012-11-09 22:03:47 +0000,dirtyvic_1,@glennbeck @seahannity Commander Fitzpatrick Files Treason Charges Against Barack Obama #teaparty #UT #Election  http://t.co/T9GHyUZ4
267024711169503232,2012-11-09 22:03:46 +0000,SteveCaruso,Great election background....http://t.co/HwdVs40N
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :count => 20}).to_return(:body => fixture("search_with_entities.json"))
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :count => 5, :max_id => 264784855672442882}).to_return(:body => fixture("search_with_entities.json"))
      end
      it "requests the correct resource" do
        @search.all("twitter")
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :count => 20})).to have_been_made
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :include_entities => 1, :count => 5, :max_id => 264784855672442882})).to have_been_made
      end
      it "decodes URLs" do
        @search.all("twitter")
        expect($stdout.string).to include "http://semver.org"
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.all("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name       Text
267024754278539266  Nov  9 14:03  @saintsday998     Murray Energy Corp. Obama...
267024753326448640  Nov  9 14:03  @thlyons          Obama Administration Exte...
267024753292869634  Nov  9 14:03  @justmaryse       Fox News accidentally ins...
267024751854252033  Nov  9 14:03  @BlueTrooth       RT @AntiWacko: It's hilar...
267024751657115648  Nov  9 14:03  @robbiegleeson    RT @Revolution_IRL: RT if...
267024751619350528  Nov  9 14:03  @melinwy          RT @Kristina_x_x: GOP ent...
267024751585808384  Nov  9 14:03  @WANT1DTOFOLLOWU  RT @LoveYungCotta: Romney...
267024751321575424  Nov  9 14:03  @bodysouls        @RealJonLovitz  Did u see...
267024750109396993  Nov  9 14:03  @tinasebring      RT @ken24xavier: YES OBAM...
267024749979373568  Nov  9 14:03  @OD_Worrell       RT @AP: White House says ...
267024749622865921  Nov  9 14:03  @LathamChalaGrp   Obama Hangs Tough on the ...
267024749501218817  Nov  9 14:03  @sesto09          La lettera di Obama sui g...
267024748779819009  Nov  9 14:03  @NickLoveSlayer   RT @NewsMCyrus: Despues D...
267024748536541185  Nov  9 14:03  @Ch_pavon17       RT @PrincipeWilli: -Hoy m...
267024746821058560  Nov  9 14:03  @weeki1           RT @jjauthor: #Navy names...
267024746724605952  Nov  9 14:03  @LugosLove        Wow, Obama Started Crying...
267024746389061633  Nov  9 14:03  @jbrons           RT @dwiskus: Obama played...
267024746372268032  Nov  9 14:03  @Moondances_      RT @_pedropenna: OBAMA te...
267024745642463233  Nov  9 14:03  @matthew_austin4  No, I will not shut up. I...
267024745546014720  Nov  9 14:03  @FreebirdForever  RT @Bobprintdoc: @vickike...
267024744673587201  Nov  9 14:03  @_WHOOPdefckindo  RT @RiIeyJokess: ME: who ...
267024743629209601  Nov  9 14:03  @nikkipjah        #Obama's track record wit...
267024743323033600  Nov  9 14:03  @pandphomemades   RT @JewPublican: Think ab...
267024742899412992  Nov  9 14:03  @Vita__Nova       Bunda rus-israil ittifakı...
267024742295416832  Nov  9 14:03  @tv6tnt           White House says Obama wi...
267024742257680386  Nov  9 14:03  @ricardo126234    @Jacquie0415 @gregwhoward...
267024741381074944  Nov  9 14:03  @LifesaBishh      RT @SomeoneBelow: The per...
267024740810637313  Nov  9 14:03  @I_Fuk_Wid_OBAMA  :) #Pixect http://t.co/jZ...
267024740760289280  Nov  9 14:03  @llParadisell     Why Libya Cover-Up: Obama...
267024739627839488  Nov  9 14:03  @naiburnwoood     RT @StephenAtHome: I stil...
267024738927394816  Nov  9 14:03  @Neo_Sweetness    RT @5oodaysofautumn: #Oba...
267024738906431490  Nov  9 14:03  @vcAraceli        RT @jusxy: Obama what's m...
267024738575065089  Nov  9 14:03  @notsoslimshadys  RT @harrynstuff: I bet on...
267024738478600192  Nov  9 14:03  @ThinksLogical    RT @dlb703: The differenc...
267024737937547264  Nov  9 14:03  @pabloirossi      Obama, ante el precipicio...
267024737794945024  Nov  9 14:03  @mermaid6590      @LeslieMHooper I think Ob...
267024737706840064  Nov  9 14:03  @n_mariee3        RT @SAMhOes: Lmao #Obama ...
267024737354534912  Nov  9 14:03  @soso2583         RT @20Minutes: Pour Obama...
267024736968667136  Nov  9 14:03  @desertkev        @k_m_allan I'm more about...
267024736373063680  Nov  9 14:03  @blakecallaway    yo why did obama have to win
267024736108818432  Nov  9 14:03  @AlondraMiaa      RT @FaithOn1D: "Las hijas...
267024735878119424  Nov  9 14:03  @4iHD             Szef CIA zrezygnował prze...
267024735450324993  Nov  9 14:03  @fcukjessi        RT @JosieNelson7: Obama y...
267024735156703232  Nov  9 14:03  @Evilazio         Obama "decepciona" mercad...
267024734628233218  Nov  9 14:03  @carolynedgar     @GoAngelo let's just spec...
267024734481440769  Nov  9 14:03  @bob_mor          RT @NoticiasCaracol: Obam...
267024734464651264  Nov  9 14:03  @NotBarack        FEMA Failed/Obama Hailed ...
267024733319598080  Nov  9 14:03  @georgiaokeeffex  Obama
267024733189582849  Nov  9 14:03  @LLW83            RT @TheDailyEdge: Obama h...
267024733067943936  Nov  9 14:03  @aylin_arellanoo  RT @lupiss14: - Ya viste ...
267024732984053761  Nov  9 14:03  @ASyrupp          @realDonaldTrump hey idio...
267024732984053760  Nov  9 14:03  @JConason         RT @HuffingtonPost: CEO w...
267024732812095488  Nov  9 14:03  @hwain_96         RT @_Ken_barlow_: Cameron...
267024731352481792  Nov  9 14:03  @shetrulylovedya  ate o obama e a familia d...
267024731193110528  Nov  9 14:03  @r9mcgon          RT @Mike_hugs: Nixon +Kis...
267024729980928000  Nov  9 14:03  @skew11           RT @RepJeffDuncan: 102 mi...
267024729972568065  Nov  9 14:03  @ayyuradita       Congratulation for barack...
267024729741877249  Nov  9 14:03  @homeoffice_biz   Hugo Chavez Offers Obama ...
267024729708298240  Nov  9 14:03  @donthebear       Bone head and Google eys ...
267024729527971841  Nov  9 14:03  @Imercuryinfo     9% Inflation, Obama Care,...
267024728898801664  Nov  9 14:03  @lege_atque_lacr  Obama holds firm to tax h...
267024728403886080  Nov  9 14:03  @vldpopov         So, selling Obama is  sim...
267024727971856384  Nov  9 14:03  @DanieMilli_anne  then they really wanna ar...
267024726549999616  Nov  9 14:03  @Says_The_King    I got me an Obama momma. ...
267024726214463488  Nov  9 14:03  @Tatts_N_Dreads   RT @CNNMoney: Gun sales a...
267024725941817345  Nov  9 14:03  @mensadude        Ron Paul: Election shows ...
267024725505622016  Nov  9 14:03  @IKrUsHiNsKi      @britney_brinae lol move ...
267024724817760256  Nov  9 14:03  @mgracer514       @SpeakerBoehner Do NOT gi...
267024724792590336  Nov  9 14:03  @leenpaape        RT @TheEconomist: Video: ...
267024724574474241  Nov  9 14:03  @Timmermanscm     RT @__Wieke__: Net als in...
267024723769176064  Nov  9 14:03  @ColeMurdock24    People who like the snow ...
267024723211333632  Nov  9 14:03  @tbest            Awesome. "@daringfireball...
267024723005808640  Nov  9 14:03  @ibtxhis_SaMone   RT @WeirdFact: President ...
267024722540244992  Nov  9 14:03  @alejandrita_lm   RT @VaneEscobarR: Las hij...
267024721495879680  Nov  9 14:03  @stewie64         RT @DanRiehl: How does th...
267024721315504128  Nov  9 14:03  @Evilpa           RT @AACONS: How does Obam...
267024720321458176  Nov  9 14:03  @DayKadence       RT @Frances_D: Pundit Pre...
267024719470002176  Nov  9 14:03  @Mel_DaOne_       Nah, that ain't right RT ...
267024719272878080  Nov  9 14:03  @Aslans_Girl      Pundit Press: What Luck! ...
267024719138660352  Nov  9 14:03  @crazyinms        RT @Clickman8: I'm sure P...
267024717301555200  Nov  9 14:03  @JaeGun_LaoLin    RT @Kennyment: POURQUOI V...
267024717028941824  Nov  9 14:03  @borealizz        RT @utaustinliberal: Jake...
267024716429139968  Nov  9 14:03  @justessheather   My uncle posted a picture...
267024716362031105  Nov  9 14:03  @maxD_ooUt        "@JennaNanci: My family i...
267024716181696512  Nov  9 14:03  @KacyleneS        RT @ArsheanaLaNesha: Whit...
267024714717884416  Nov  9 14:03  @Imercuryinfo     I uploaded a @YouTube vid...
267024714566885376  Nov  9 14:03  @MuslimGeezer     Aung San Suu Kyi initiall...
267024714407493632  Nov  9 14:03  @MDiPasquale1999  @MarciaCM1 @royparrish of...
267024713979662336  Nov  9 14:03  @TigerBaby84      RT @BreitbartNews: Obama:...
267024713883193344  Nov  9 14:03  @CriticalMassTX   RT @thinkprogress: The 6 ...
267024713161781250  Nov  9 14:03  @cobe001001       RT @whitehouse: President...
267024713157578752  Nov  9 14:03  @MeganPanatier    City of Obama to invite O...
267024712977219584  Nov  9 14:03  @Katie_janca      RT @140elect: Hillary Cli...
267024712549400576  Nov  9 14:03  @Linapooh1        Sumbody had to do it!! Th...
267024712264212480  Nov  9 14:03  @cinrui           RT @SeanKCarter: Oliver S...
267024712247435264  Nov  9 14:03  @nthowa2          Obama in a cover up folks...
267024711932858368  Nov  9 14:03  @dirtyvic_1       @glennbeck @seahannity Co...
267024711169503232  Nov  9 14:03  @SteveCaruso      Great election background...
        eos
      end
    end
    context "--number" do
      before do
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "1"}).to_return(:body => fixture("search.json"))
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "200"}).to_return(:body => fixture("search.json"))
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "103", :max_id => "267024711169503231"}).to_return(:body => fixture("search.json"))
        stub_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "5", :max_id => "267024711169503231"}).to_return(:body => fixture("search.json"))
      end
      it "limits the number of results to 1" do
        @search.options = @search.options.merge("number" => 1)
        results = @search.all("twitter")
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "1"})).to have_been_made
      end
      it "limits the number of results to 201" do
        @search.options = @search.options.merge("number" => 201)
        @search.all("twitter")
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "200"})).to have_been_made
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "103", :max_id => "267024711169503231"})).to have_been_made
        expect(a_get("/1.1/search/tweets.json").with(:query => {:q => "twitter", :count => "5", :max_id => "267024711169503231"})).to have_been_made
      end
    end
  end

  describe "#favorites" do
    before do
      stub_get("/1.1/favorites/list.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"))
      stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.favorites("twitter")
      expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "has the correct output" do
      @search.favorites("twitter")
      expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.favorites("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.favorites("twitter")
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1})).to have_been_made
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"})).to have_been_made
      end
      it "decodes URLs" do
        @search.favorites("twitter")
        expect($stdout.string).to include "https://twitter.com/sferik/status/243988000076337152"
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.favorites("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.favorites("twitter")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.favorites("sferik", "twitter")
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"})).to have_been_made
      end
      it "has the correct output" do
        @search.favorites("sferik", "twitter")
        expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

        eos
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"))
          stub_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"}).to_return(:body => fixture("empty_array.json"))
        end
        it "requests the correct resource" do
          @search.favorites("7505382", "twitter")
          expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/favorites/list.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"})).to have_been_made
        end
        it "has the correct output" do
          @search.favorites("7505382", "twitter")
          expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

          eos
        end
      end
    end
  end

  describe "#mentions" do
    before do
      stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"))
      stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.mentions("twitter")
      expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "has the correct output" do
      @search.mentions("twitter")
      expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.mentions("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.mentions("twitter")
        expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1})).to have_been_made
        expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937"})).to have_been_made
      end
      it "decodes URLs" do
        @search.mentions("twitter")
        expect($stdout.string).to include "https://twitter.com/sferik/status/243988000076337152"
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.mentions("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.mentions("twitter")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/statuses/mentions_timeline.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
  end

  describe "#list" do
    before do
      stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("statuses.json"))
      stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.list("presidents", "twitter")
      expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
      expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
    end
    it "has the correct output" do
      @search.list("presidents", "twitter")
      expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.list("presidents", "twitter")
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :include_entities => 1, :max_id => "244099460672679937", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
      end
      it "decodes URLs" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to include "https://dev.twitter.com/docs/api/post/direct_messages/destroy"
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.list("presidents", "twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "with a user passed" do
      it "requests the correct resource" do
        @search.list("testcli/presidents", "twitter")
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"}).to_return(:body => fixture("statuses.json"))
          stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_id => "7505382", :slug => "presidents"}).to_return(:body => fixture("empty_array.json"))
        end
        it "requests the correct resource" do
          @search.list("7505382/presidents", "twitter")
          expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_id => "7505382", :slug => "presidents"})).to have_been_made
          expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :max_id => "244099460672679937", :owner_id => "7505382", :slug => "presidents"})).to have_been_made
        end
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"}).to_return(:status => 502)
        expect do
          @search.list("presidents", "twitter")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/lists/statuses.json").with(:query => {:count => "200", :owner_screen_name => "testcli", :slug => "presidents"})).to have_been_made.times(3)
      end
    end
  end

  describe "#retweets" do
    before do
      stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"}).to_return(:body => fixture("statuses.json"))
      stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.retweets("mosaic")
      expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"})).to have_been_made
      expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :max_id => "244102729860009983"})).to have_been_made.times(2)
    end
    it "has the correct output" do
      @search.retweets("mosaic")
      expect($stdout.string).to eq <<-eos
   @calebelston
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.retweets("mosaic")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244108728834592770,2012-09-07 16:23:50 +0000,calebelston,RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.retweets("mosaic")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true"})).to have_been_made
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_entities => 1, :include_rts => "true", :max_id => "244102729860009983"})).to have_been_made.times(2)
      end
      it "decodes URLs" do
        @search.retweets("mosaic")
        expect($stdout.string).to include "http://heymosaic.com/i/1Z8ssK"
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.retweets("mosaic")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name   Text
244108728834592770  Sep  7 08:23  @calebelston  RT @olivercameron: Mosaic loo...
        eos
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"}).to_return(:status => 502)
        expect do
          @search.retweets("mosaic")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.retweets("sferik", "mosaic")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :screen_name => "sferik", :max_id => "244102729860009983"})).to have_been_made.times(2)
      end
      it "has the correct output" do
        @search.retweets("sferik", "mosaic")
        expect($stdout.string).to eq <<-eos
   @calebelston
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

        eos
      end
      context "--id" do
        before do
          @search.options = @search.options.merge("id" => true)
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"))
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"}).to_return(:body => fixture("empty_array.json"))
        end
        it "requests the correct resource" do
          @search.retweets("7505382", "mosaic")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :include_rts => "true", :user_id => "7505382", :max_id => "244102729860009983"})).to have_been_made.times(2)
        end
        it "has the correct output" do
          @search.retweets("7505382", "mosaic")
          expect($stdout.string).to eq <<-eos
   @calebelston
   RT @olivercameron: Mosaic looks cool: http://t.co/A8013C9k

          eos
        end
      end
    end
  end

  describe "#timeline" do
    before do
      stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"}).to_return(:body => fixture("statuses.json"))
      stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.timeline("twitter")
      expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"})).to have_been_made
      expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937"})).to have_been_made
    end
    it "has the correct output" do
      @search.timeline("twitter")
      expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

      eos
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.timeline("twitter")
        expect($stdout.string).to eq <<-eos
ID,Posted at,Screen name,Text
244102209942458368,2012-09-07 15:57:56 +0000,sferik,"@episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem to be missing ""1.1"" from the URL."
244100411563339777,2012-09-07 15:50:47 +0000,sferik,@episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?
        eos
      end
    end
    context "--decode-uris" do
      before(:each) do
        @search.options = @search.options.merge("decode_uris" => true)
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_entities => 1}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :include_entities => 1}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.timeline("twitter")
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_entities => 1})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :include_entities => 1})).to have_been_made
      end
      it "decodes URLs" do
        @search.timeline("twitter")
        expect($stdout.string).to include "https://dev.twitter.com/docs/api/post/direct_messages/destroy"
      end
    end
    context "--exclude=replies" do
      before do
        @search.options = @search.options.merge("exclude" => "replies")
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
      end
      it "excludes replies" do
        @search.timeline
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true"})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :exclude_replies => "true", :max_id => "244099460672679937"})).to have_been_made
      end
    end
    context "--exclude=retweets" do
      before do
        @search.options = @search.options.merge("exclude" => "retweets")
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false", :max_id => "244099460672679937"}).to_return(:body => fixture("empty_array.json"))
      end
      it "excludes retweets" do
        @search.timeline
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false"})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :include_rts => "false", :max_id => "244099460672679937"})).to have_been_made
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
        @search.timeline("twitter")
        expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
        eos
      end
    end
    context "--max-id" do
      before do
        @search.options = @search.options.merge("max_id" => 244104558433951744)
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244104558433951744"}).to_return(:body => fixture("statuses.json"))
      end
      it "requests the correct resource" do
        @search.timeline("twitter")
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244104558433951744"})).to have_been_made
      end
    end
    context "--since-id" do
      before do
        @search.options = @search.options.merge("since_id" => 244104558433951744)
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :since_id => "244104558433951744"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :since_id => "244104558433951744"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.timeline("twitter")
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :since_id => "244104558433951744"})).to have_been_made
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :since_id => "244104558433951744"})).to have_been_made
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"}).to_return(:status => 502)
        expect do
          @search.timeline("twitter")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/statuses/home_timeline.json").with(:query => {:count => "200"})).to have_been_made.times(3)
      end
    end
    context "with a user passed" do
      before do
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik"}).to_return(:body => fixture("statuses.json"))
        stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"}).to_return(:body => fixture("empty_array.json"))
      end
      it "requests the correct resource" do
        @search.timeline("sferik", "twitter")
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik"})).to have_been_made
        expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :screen_name => "sferik"})).to have_been_made
      end
      it "has the correct output" do
        @search.timeline("sferik", "twitter")
        expect($stdout.string).to eq <<-eos
   @sferik
   @episod @twitterapi now https://t.co/I17jUTu2 and https://t.co/deDu4Hgw seem 
   to be missing "1.1" from the URL.

   @sferik
   @episod @twitterapi Did you catch https://t.co/VHsQvZT0 as well?

        eos
      end
      context "--csv" do
        before do
          @search.options = @search.options.merge("csv" => true)
        end
        it "outputs in CSV format" do
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
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :user_id => "7505382"}).to_return(:body => fixture("statuses.json"))
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"}).to_return(:body => fixture("empty_array.json"))
        end
        it "requests the correct resource" do
          @search.timeline("7505382", "twitter")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :user_id => "7505382"})).to have_been_made
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :max_id => "244099460672679937", :user_id => "7505382"})).to have_been_made
        end
      end
      context "--long" do
        before do
          @search.options = @search.options.merge("long" => true)
        end
        it "outputs in long format" do
          @search.timeline("sferik", "twitter")
          expect($stdout.string).to eq <<-eos
ID                  Posted at     Screen name  Text
244102209942458368  Sep  7 07:57  @sferik      @episod @twitterapi now https:...
244100411563339777  Sep  7 07:50  @sferik      @episod @twitterapi Did you ca...
          eos
        end
      end
      context "--max-id" do
        before do
          @search.options = @search.options.merge("max_id" => 244104558433951744)
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244104558433951744"}).to_return(:body => fixture("statuses.json"))
        end
        it "requests the correct resource" do
          @search.timeline("sferik", "twitter")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244104558433951744"})).to have_been_made
        end
      end
      context "--since-id" do
        before do
          @search.options = @search.options.merge("since_id" => 244104558433951744)
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :since_id => "244104558433951744"}).to_return(:body => fixture("statuses.json"))
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244099460672679937", :since_id => "244104558433951744"}).to_return(:body => fixture("empty_array.json"))
        end
        it "requests the correct resource" do
          @search.timeline("sferik", "twitter")
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :since_id => "244104558433951744"})).to have_been_made
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:count => "200", :screen_name => "sferik", :max_id => "244099460672679937", :since_id => "244104558433951744"})).to have_been_made
        end
      end
      context "Twitter is down" do
        it "retries 3 times and then raise an error" do
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik", :count => "200"}).to_return(:status => 502)
          expect do
            @search.timeline("sferik", "twitter")
          end.to raise_error(Twitter::Error::BadGateway)
          expect(a_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik", :count => "200"})).to have_been_made.times(3)
        end
      end
    end
  end

  describe "#users" do
    before do
      stub_get("/1.1/users/search.json").with(:query => {:page => "1", :q => "Erik"}).to_return(:body => fixture("users.json"))
      stub_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik"}).to_return(:body => fixture("empty_array.json"))
    end
    it "requests the correct resource" do
      @search.users("Erik")
      1.upto(50).each do |page|
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "1", :q => "Erik"})).to have_been_made
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik"})).to have_been_made
      end
    end
    it "has the correct output" do
      @search.users("Erik")
      expect($stdout.string.chomp).to eq "pengwynn  sferik"
    end
    context "--csv" do
      before do
        @search.options = @search.options.merge("csv" => true)
      end
      it "outputs in CSV format" do
        @search.users("Erik")
        expect($stdout.string).to eq <<-eos
ID,Since,Last tweeted at,Tweets,Favorites,Listed,Following,Followers,Screen name,Name,Verified,Protected,Bio,Status,Location,URL
14100886,2008-03-08 16:34:22 +0000,2012-07-07 20:33:19 +0000,6940,192,358,3427,5457,pengwynn,Wynn Netherland,false,false,"Christian, husband, father, GitHubber, Co-host of @thechangelog, Co-author of Sass, Compass, #CSS book  http://wynn.fm/sass-meap",@akosmasoftware Sass book! @hcatlin @nex3 are the brains behind Sass. :-),"Denton, TX",http://wynnnetherland.com
7505382,2007-07-16 12:59:01 +0000,2012-07-08 18:29:20 +0000,7890,3755,118,212,2262,sferik,Erik Michaels-Ober,false,false,Vagabond.,@goldman You're near my home town! Say hi to Woodstock for me.,San Francisco,https://github.com/sferik
        eos
      end
    end
    context "--long" do
      before do
        @search.options = @search.options.merge("long" => true)
      end
      it "outputs in long format" do
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
      it "reverses the order of the sort" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=favorites" do
      before do
        @search.options = @search.options.merge("sort" => "favorites")
      end
      it "sorts by number of favorites" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--sort=followers" do
      before do
        @search.options = @search.options.merge("sort" => "followers")
      end
      it "sorts by number of followers" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=friends" do
      before do
        @search.options = @search.options.merge("sort" => "friends")
      end
      it "sorts by number of friends" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=listed" do
      before do
        @search.options = @search.options.merge("sort" => "listed")
      end
      it "sorts by number of list memberships" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=since" do
      before do
        @search.options = @search.options.merge("sort" => "since")
      end
      it "sorts by the time wshen Twitter account was created" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "sferik    pengwynn"
      end
    end
    context "--sort=tweets" do
      before do
        @search.options = @search.options.merge("sort" => "tweets")
      end
      it "sorts by number of Tweets" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--sort=tweeted" do
      before do
        @search.options = @search.options.merge("sort" => "tweeted")
      end
      it "sorts by the time of the last Tweet" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "--unsorted" do
      before do
        @search.options = @search.options.merge("unsorted" => true)
      end
      it "is not sorted" do
        @search.users("Erik")
        expect($stdout.string.chomp).to eq "pengwynn  sferik"
      end
    end
    context "Twitter is down" do
      it "retries 3 times and then raise an error" do
        stub_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik", }).to_return(:status => 502)
        expect do
          @search.users("Erik")
        end.to raise_error(Twitter::Error::BadGateway)
        expect(a_get("/1.1/users/search.json").with(:query => {:page => "2", :q => "Erik", })).to have_been_made.times(3)
      end
    end
  end

end
