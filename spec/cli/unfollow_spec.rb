# encoding: utf-8
require 'helper'

describe T::CLI::Unfollow do

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
        @t.unfollow("listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("listed", "presidents")
        $stdout.string.chomp.should == "@testcli is already not following any list members."
      end
    end
    context "one user" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          to_return(:body => fixture("users_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("listed", "presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_get("/1/lists/members.json").
          with(:query => {:cursor => "-1", :include_entities => "false", :owner_screen_name => "sferik", :skip_status => "true", :slug => "presidents"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("listed", "presidents")
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("listed", "presidents")
          $stdout.string.chomp.should == ""
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:status => 502)
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          lambda do
            @t.unfollow("listed", "presidents")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#followers" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no followers" do
      before do
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("followers")
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("followers")
        $stdout.string.chomp.should == "@testcli is already not following any followers."
      end
    end
    context "one follower" do
      before do
        stub_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("followers_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("followers")
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("followers")
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("followers")
          $stdout.string.chomp.should == ""
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:status => 502)
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          lambda do
            @t.unfollow("followers")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#friends" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no friends" do
      before do
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("empty_cursor.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("friends")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("friends")
        $stdout.string.chomp.should == "@testcli is already not following anyone."
      end
    end
    context "four friends" do
      before do
        @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
        stub_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          to_return(:body => fixture("friends_ids.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("friends")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("friends")
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("friends")
          $stdout.string.chomp.should == ""
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:status => 502)
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          lambda do
            @t.unfollow("friends")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            should have_been_made.times(3)
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
        @t.unfollow("nonfollowers")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("nonfollowers")
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
      end
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
        $stdin.should_receive(:gets).and_return("yes")
        @t.unfollow("nonfollowers")
        a_get("/1/friends/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_get("/1/followers/ids.json").
          with(:query => {:cursor => "-1"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:user_id => "7505382", :include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          @t.unfollow("nonfollowers")
          $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("no")
          @t.unfollow("nonfollowers")
          $stdout.string.chomp.should == ""
        end
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            to_return(:status => 502)
          $stdout.should_receive(:print).with("Are you sure you want to unfollow 1 user? ")
          $stdin.should_receive(:gets).and_return("yes")
          lambda do
            @t.unfollow("nonfollowers")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:user_id => "7505382", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

  describe "#users" do
    before do
      @t.options = @t.options.merge(:profile => fixture_path + "/.trc")
    end
    context "no users" do
      it "should exit" do
        lambda do
          @t.follow("users")
        end.should raise_error
      end
    end
    context "one user" do
      it "should request the correct resource" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.unfollow("users", "sferik")
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @t.unfollow("users", "sferik")
        $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
      end
      context "Twitter is down" do
        it "should retry 3 times and then raise an error" do
          stub_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            to_return(:status => 502)
          lambda do
            @t.unfollow("users", "sferik")
          end.should raise_error("Twitter is down or being upgraded.")
          a_delete("/1/friendships/destroy.json").
            with(:query => {:screen_name => "sferik", :include_entities => "false"}).
            should have_been_made.times(3)
        end
      end
    end
  end

end
