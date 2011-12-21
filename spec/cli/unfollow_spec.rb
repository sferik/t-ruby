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
      before do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("users", "sferik")
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("users", "sferik")
        $stdout.string.should =~ /^@testcli is no longer following 1 user\.$/
      end
    end
    context "two users" do
      before do
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        stub_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "gem", :include_entities => "false"}).
          to_return(:body => fixture("gem.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        @t.unfollow("users", "sferik", "gem")
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "sferik", :include_entities => "false"}).
          should have_been_made
        a_delete("/1/friendships/destroy.json").
          with(:query => {:screen_name => "gem", :include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @t.unfollow("users", "sferik", "gem")
        $stdout.string.should =~ /^@testcli is no longer following 2 users\.$/
      end
    end
  end

end
