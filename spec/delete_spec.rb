# encoding: utf-8
require 'helper'

describe T::Delete do

  before do
    rcfile = RCFile.instance
    rcfile.path = fixture_path + "/.trc"
    @delete = T::Delete.new
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#block" do
    before do
      @delete.options = @delete.options.merge(:profile => fixture_path + "/.trc")
      stub_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @delete.block("sferik")
      a_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik", :include_entities => "false"}).
        should have_been_made
    end
    it "should have the correct output" do
      @delete.block("sferik")
      $stdout.string.should =~ /^@testcli unblocked @sferik\.$/
    end
  end

  describe "#dm" do
    before do
      @delete.options = @delete.options.merge(:profile => fixture_path + "/.trc")
      stub_delete("/1/direct_messages/destroy/1773478249.json").
        with(:query => {:include_entities => "false"}).
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context ":force => true" do
      before do
        @delete.options = @delete.options.merge(:force => true)
      end
      it "should request the correct resource" do
        @delete.dm("1773478249")
        a_delete("/1/direct_messages/destroy/1773478249.json").
          with(:query => {:include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @delete.dm("1773478249")
        $stdout.string.chomp.should == "@testcli deleted the direct message sent to @pengwynn: \"Creating a fixture for the Twitter gem\""
      end
    end
    context ":force => false" do
      before do
        @delete.options = @delete.options.merge(:force => false)
        stub_get("/1/direct_messages/show/1773478249.json").
          with(:query => {:include_entities => "false"}).
          to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to permanently delete the direct message to @pengwynn: \"Creating a fixture for the Twitter gem\"? [y/N] ")
        $stdin.should_receive(:gets).and_return("yes")
        @delete.dm("1773478249")
        a_get("/1/direct_messages/show/1773478249.json").
          with(:query => {:include_entities => "false"}).
          should have_been_made
        a_delete("/1/direct_messages/destroy/1773478249.json").
          with(:query => {:include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete the direct message to @pengwynn: \"Creating a fixture for the Twitter gem\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("yes")
          @delete.dm("1773478249")
          $stdout.string.chomp.should == "@testcli deleted the direct message sent to @pengwynn: \"Creating a fixture for the Twitter gem\""
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete the direct message to @pengwynn: \"Creating a fixture for the Twitter gem\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("no")
          @delete.dm("1773478249")
          $stdout.string.chomp.should be_empty
        end
      end
    end
  end

  describe "#favorite" do
    before do
      @delete.options = @delete.options.merge(:profile => fixture_path + "/.trc")
      stub_delete("/1/favorites/destroy/28439861609.json").
        with(:query => {:include_entities => "false"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context ":force => true" do
      before do
        @delete.options = @delete.options.merge(:force => true)
      end
      it "should request the correct resource" do
        @delete.favorite("28439861609")
        a_delete("/1/favorites/destroy/28439861609.json").
          with(:query => {:include_entities => "false"}).
          should have_been_made
      end
      it "should have the correct output" do
        @delete.favorite("28439861609")
        $stdout.string.should =~ /^@testcli unfavorited @sferik's status: "The problem with your code is that it's doing exactly what you told it to do\."$/
      end
    end
    context ":force => false" do
      before do
        @delete.options = @delete.options.merge(:force => false)
        stub_get("/1/statuses/show/28439861609.json").
          with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
          to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to delete the favorite of @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
        $stdin.should_receive(:gets).and_return("yes")
        @delete.favorite("28439861609")
        a_get("/1/statuses/show/28439861609.json").
          with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
          should have_been_made
        a_delete("/1/favorites/destroy/28439861609.json").
          with(:query => {:include_entities => "false"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to delete the favorite of @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("yes")
          @delete.favorite("28439861609")
          $stdout.string.should =~ /^@testcli unfavorited @sferik's status: "The problem with your code is that it's doing exactly what you told it to do\."$/
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to delete the favorite of @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("no")
          @delete.favorite("28439861609")
          $stdout.string.chomp.should be_empty
        end
      end
    end
  end

  describe "#list" do
    before do
      @delete.options = @delete.options.merge(:profile => fixture_path + "/.trc")
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/lists/destroy.json").
        with(:query => {:owner_screen_name => "sferik", :slug => "presidents"}).
        to_return(:body => fixture("list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context ":force => true" do
      before do
        @delete.options = @delete.options.merge(:force => true)
      end
      it "should request the correct resource" do
        @delete.list("presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_delete("/1/lists/destroy.json").
          with(:query => {:owner_screen_name => "sferik", :slug => "presidents"}).
          should have_been_made
      end
      it "should have the correct output" do
        @delete.list("presidents")
        $stdout.string.chomp.should == "@testcli deleted the list \"presidents\"."
      end
    end
    context ":force => false" do
      before do
        @delete.options = @delete.options.merge(:force => false)
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to permanently delete the list \"presidents\"? [y/N] ")
        $stdin.should_receive(:gets).and_return("yes")
        @delete.list("presidents")
        a_get("/1/account/verify_credentials.json").
          should have_been_made
        a_delete("/1/lists/destroy.json").
          with(:query => {:owner_screen_name => "sferik", :slug => "presidents"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete the list \"presidents\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("yes")
          @delete.list("presidents")
          $stdout.string.chomp.should == "@testcli deleted the list \"presidents\"."
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete the list \"presidents\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("no")
          @delete.list("presidents")
          $stdout.string.chomp.should be_empty
        end
      end
    end
  end

  describe "#status" do
    before do
      @delete.options = @delete.options.merge(:profile => fixture_path + "/.trc")
      stub_delete("/1/statuses/destroy/26755176471724032.json").
        with(:query => {:include_entities => "false", :trim_user => "true"}).
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    context ":force => true" do
      before do
        @delete.options = @delete.options.merge(:force => true)
      end
      it "should request the correct resource" do
        @delete.status("26755176471724032")
        a_delete("/1/statuses/destroy/26755176471724032.json").
          with(:query => {:include_entities => "false", :trim_user => "true"}).
          should have_been_made
      end
      it "should have the correct output" do
        @delete.status("26755176471724032")
        $stdout.string.chomp.should == "@testcli deleted the status: \"The problem with your code is that it's doing exactly what you told it to do.\""
      end
    end
    context ":force => false" do
      before do
        @delete.options = @delete.options.merge(:force => false)
        stub_get("/1/statuses/show/26755176471724032.json").
          with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
          to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      end
      it "should request the correct resource" do
        $stdout.should_receive(:print).with("Are you sure you want to permanently delete @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
        $stdin.should_receive(:gets).and_return("yes")
        @delete.status("26755176471724032")
        a_get("/1/statuses/show/26755176471724032.json").
          with(:query => {:include_entities => "false", :include_my_retweet => "false", :trim_user => "true"}).
          should have_been_made
        a_delete("/1/statuses/destroy/26755176471724032.json").
          with(:query => {:include_entities => "false", :trim_user => "true"}).
          should have_been_made
      end
      context "yes" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("yes")
          @delete.status("26755176471724032")
          $stdout.string.chomp.should == "@testcli deleted the status: \"The problem with your code is that it's doing exactly what you told it to do.\""
        end
      end
      context "no" do
        it "should have the correct output" do
          $stdout.should_receive(:print).with("Are you sure you want to permanently delete @sferik's status: \"The problem with your code is that it's doing exactly what you told it to do.\"? [y/N] ")
          $stdin.should_receive(:gets).and_return("no")
          @delete.status("26755176471724032")
          $stdout.string.chomp.should be_empty
        end
      end
    end
  end

end
