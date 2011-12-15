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
      $stdout.string.should =~ /@testcli added 1 user to the list: presidents\./
    end
  end

end
