# encoding: utf-8
require 'helper'

describe T::CLI::List::Add do

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

  describe "#friends" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "no friends" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "friends", "presidents")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "friends", "presidents")
        $stdout.string.chomp.should == "All of @testcli's friends are already members of the list \"presidents\"."
      end
    end
    context "one friend" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to add 1 friend to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "friends", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 1 friend to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "friends", "presidents")
          $stdout.string.should =~ /@testcli added 1 friend to the list "presidents"\./
        end
        context "Twitter is down" do
          it "should retry 3 times and then raise an error" do
            stub_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
              to_return(:status => 502)
            $stdout.should_receive(:print).with("Are you sure you want to add 1 friend to the list \"presidents\"? ")
            $stdin.should_receive(:gets).and_return("yes")
            lambda do
              @t.list("add", "friends", "presidents")
            end.should raise_error("Twitter is down or being upgraded.")
            a_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
              should have_been_made.times(3)
          end
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 1 friend to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "friends", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "501 users" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("501_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 friends to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "friends", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(5)
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 friends to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "friends", "presidents")
          $stdout.string.should =~ /@testcli added 500 friends to the list "presidents"\./
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 friends to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "friends", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "500 list members" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("501_users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "friends", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "friends", "presidents")
        $stdout.string.chomp.should == "The list \"presidents\" are already contains the maximum of 500 members."
      end
    end
  end

  describe "#followers" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context "no followers" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "followers", "presidents")
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "followers", "presidents")
        $stdout.string.chomp.should == "All of @testcli's followers are already members of the list \"presidents\"."
      end
    end
    context "two followers" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "213747670,428004849", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to add 2 followers to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "followers", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "213747670,428004849", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 2 followers to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "followers", "presidents")
          $stdout.string.should =~ /@testcli added 2 followers to the list "presidents"\./
        end
        context "Twitter is down" do
          it "should retry 3 times and then raise an error" do
            stub_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "213747670,428004849", :slug => "presidents", :owner_screen_name => "sferik"}).
              to_return(:status => 502)
            $stdout.should_receive(:print).with("Are you sure you want to add 2 followers to the list \"presidents\"? ")
            $stdin.should_receive(:gets).and_return("yes")
            lambda do
              @t.list("add", "followers", "presidents")
            end.should raise_error("Twitter is down or being upgraded.")
            a_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "213747670,428004849", :slug => "presidents", :owner_screen_name => "sferik"}).
              should have_been_made.times(3)
          end
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 2 followers to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "followers", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "501 users" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("501_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 followers to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "followers", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(5)
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 followers to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "followers", "presidents")
          $stdout.string.should =~ /@testcli added 500 followers to the list "presidents"\./
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 followers to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "followers", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "500 list members" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("501_users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "followers", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "followers", "presidents")
        $stdout.string.chomp.should == "The list \"presidents\" are already contains the maximum of 500 members."
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
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "listed", "democrats", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "listed", "democrats", "presidents")
        $stdout.string.chomp.should == "All of the members of the list \"democrats\" are already members of the list \"presidents\"."
      end
    end
    context "one user" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to add 1 member to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "listed", "democrats", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 1 member to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "listed", "democrats", "presidents")
          $stdout.string.should =~ /@testcli added 1 member to the list "presidents"\./
        end
        context "Twitter is down" do
          it "should retry 3 times and then raise an error" do
            stub_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
              to_return(:status => 502)
            $stdout.should_receive(:print).with("Are you sure you want to add 1 member to the list \"presidents\"? ")
            $stdin.should_receive(:gets).and_return("yes")
            lambda do
              @t.list("add", "listed", "democrats", "presidents")
            end.should raise_error("Twitter is down or being upgraded.")
            a_post("/1/lists/members/create_all.json").
              with(:body => {:user_id => "7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
              should have_been_made.times(3)
          end
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to add 1 member to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "listed", "democrats", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "501 users" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          to_return(:body => fixture("501_users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 members to the list \"presidents\"? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.list("add", "listed", "democrats", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "democrats"}).
          should have_been_made
        a_post("/1/lists/members/create_all.json").
          with(:body => {:user_id => "7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382,7505382", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(5)
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 members to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.list("add", "listed", "democrats", "presidents")
          $stdout.string.should =~ /@testcli added 500 members to the list "presidents"\./
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Lists can't have more than 500 members. Do you want to add up to 500 members to the list \"presidents\"? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.list("add", "listed", "democrats", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
    context "500 list members" do
      before do
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("501_users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.list("add", "listed", "democrats", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.list("add", "listed", "democrats", "presidents")
        $stdout.string.chomp.should == "The list \"presidents\" are already contains the maximum of 500 members."
      end
    end
  end

  describe "#users" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_post("/1/lists/members/create_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.list("add", "users", "presidents", "sferik")
      a_get("/1/account/verify_credentials.json").
        should have_been_made
      a_post("/1/lists/members/create_all.json").
        with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.list("add", "users", "presidents", "sferik")
      $stdout.string.should =~ /@testcli added 1 user to the list "presidents"\./
    end
    context "Twitter is down" do
      it "should retry 3 times and then raise an error" do
        stub_post("/1/lists/members/create_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          to_return(:status => 502)
        lambda do
          @t.list("add", "users", "presidents", "sferik")
        end.should raise_error("Twitter is down or being upgraded.")
        a_post("/1/lists/members/create_all.json").
          with(:body => {:screen_name => "sferik", :slug => "presidents", :owner_screen_name => "sferik"}).
          should have_been_made.times(3)
      end
    end
  end

end
