# encoding: utf-8
require 'helper'

describe T::CLI::Follow::All do

  before do
    @t = T::CLI.new
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#followers" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      before do
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.follow("all", "followers")
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.follow("all", "followers")
        $stdout.string.chomp.should == "@testcli is already following all of his or her followers."
      end
    end
    context "one user" do
      before do
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/friendships/create.json").
          with(:body => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.follow("all", "followers")
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1/friendships/create.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.follow("all", "followers")
          $stdout.string.should =~ /^@testcli is now following @sferik\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.follow("all", "followers")
          $stdout.string.chomp.should == ""
        end
      end
    end
  end

  describe "#listed" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "no users" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.follow("all", "listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.follow("all", "listed", "presidents")
        $stdout.string.chomp.should == "@testcli is already following all list members."
      end
    end
    context "one user" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/friendships/create.json").
          with(:body => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.follow("all", "listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_post("/1/friendships/create.json").
          with(:body => {:user_id => "7505382"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.follow("all", "listed", "presidents")
          $stdout.string.should =~ /^@testcli is now following @sferik\.$/
          $stdout.string.should =~ /^@testcli is now following 1 more user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to follow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.follow("all", "listed", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
  end

end
