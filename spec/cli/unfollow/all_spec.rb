# encoding: utf-8
require 'helper'

describe T::CLI::Unfollow::All do

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
        @t.unfollow("all", "listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("all", "listed", "presidents")
        $stdout.string.chomp.should == "@testcli is already not following any list members."
      end
    end
    context "one user" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("all", "listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("all", "listed", "presidents")
          $stdout.string.should =~ /^@testcli is no longer following @sferik\.$/
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("all", "listed", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
    end
  end

  describe "#nonfollowers" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      before do
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("all", "nonfollowers")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("all", "nonfollowers")
        $stdout.string.chomp.should == "@testcli is already not following any non-followers."
      end
    end
    context "one user" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("all", "nonfollowers")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("all", "nonfollowers")
          $stdout.string.should =~ /^@testcli is no longer following @sferik\.$/
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("all", "nonfollowers")
          $stdout.string.chomp.should == ""
        end
      end
    end
  end

  describe "#users" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      before do
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("all", "users")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("all", "users")
        $stdout.string.chomp.should == "@testcli is already not following anyone."
      end
    end
    context "four users" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("all", "users")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("all", "users")
          $stdout.string.should =~ /^@testcli is no longer following @sferik\.$/
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("all", "users")
          $stdout.string.chomp.should == ""
        end
      end
    end
  end

end
