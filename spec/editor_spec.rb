# encoding: utf-8
require 'helper'

describe T::Editor do

  context "when generating a tempfile" do
    it "appends with default filler text" do
      expect(T::Editor.tempfile.read).to eq("\n# Enter your tweet above.")
    end

    it "starts with specified filler text" do
      expect(T::Editor.tempfile("# Oh yeah.").read).to eq("# Oh yeah.")
    end
  end

  context "when editing a file" do
    before(:all) do
      T::Editor.stub(:edit) do |path|
        File.open(path, "wb") do |f|
          f.write("A tweet!!!!")
        end
      end
    end

    it "fetches your tweet content without comments" do
      expect(T::Editor.gets(:update)).to eq("A tweet!!!!")
    end
  end

  context "when fetching the editor to write in" do
    context "no $VISUAL or $EDITOR set" do
      before(:all) do
        ENV["EDITOR"] = ENV["VISUAL"] = nil
        RbConfig::CONFIG['host_os'] = "darwin12.2.0"
      end

      it "returns the system editor" do
        expect(T::Editor.editor).to eq("vi")
      end
    end

    context "$VISUAL is set" do
      before(:all) do
        ENV["EDITOR"] = nil
        ENV["VISUAL"] = "/my/vim/install"
      end

      it "returns the system editor" do
        expect(T::Editor.editor).to eq("/my/vim/install")
      end
    end

    context "$EDITOR is set" do
      before(:all) do
        ENV["EDITOR"] = "/usr/bin/subl"
        ENV["VISUAL"] = nil
      end

      it "returns the system editor" do
        expect(T::Editor.editor).to eq("/usr/bin/subl")
      end
    end

    context "$VISUAL and $EDITOR are set" do
      before(:all) do
        ENV["EDITOR"] = "/my/vastly/superior/editor"
        ENV["VISUAL"] = "/usr/bin/emacs"
      end

      it "returns the system editor" do
        expect(T::Editor.editor).to eq("/usr/bin/emacs")
      end
    end
  end

  context "when fetching system editor" do
    context "on a mac" do
      before(:all) do
        RbConfig::CONFIG['host_os'] = "darwin12.2.0"
      end
      it "returns 'vi' on a unix machine" do
        expect(T::Editor.system_editor).to eq("vi")
      end
    end

    context "on a Windows POC" do
      before(:all) do
        RbConfig::CONFIG['host_os'] = "mswin"
      end
      it "returns 'notepad' on a windows box" do
        expect(T::Editor.system_editor).to eq("notepad")
      end
    end
  end

end
