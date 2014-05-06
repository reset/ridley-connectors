require 'spec_helper'

describe Ridley::CommandContext::UnixUpdateOmnibus, focus: true do
  let(:unix_update_omnibus) { described_class.new }

  describe "::new" do
    context "when a chef_version is not given" do
      it "chef_version is set to latest" do
        expect(unix_update_omnibus.chef_version).to eql("latest")
      end
    end

    context "when prerelease is not given" do
      it "prerelease is set to false" do
        expect(unix_update_omnibus.prerelease).to be_false
      end
    end

    context "when options are set" do
      let(:unix_update_omnibus) { described_class.new(options) }
      let(:options) do
        {
          chef_version: "1.2.3",
          prerelease: true,
          direct_url: "http://my.package.com/"
        }
      end

      it "sets chef_version" do
        expect(unix_update_omnibus.chef_version).to eql("1.2.3")
      end

      it "sets prerelease" do
        expect(unix_update_omnibus.prerelease).to be_true
      end

      it "sets direct_url" do
        expect(unix_update_omnibus.direct_url).to eql("http://my.package.com/")
      end
    end
  end

  describe "#command" do
    it "returns a string" do
      expect(unix_update_omnibus.command).to be_a(String)
    end
  end

  describe "#tmp_path" do
    it "returns a string" do
      expect(unix_update_omnibus.tmp_path).to be_a(String)
    end
  end

  describe "#upgrade_solo_rb_path" do
    it "returns a string" do
      expect(unix_update_omnibus.upgrade_solo_rb_path).to be_a(String)
    end
  end

  describe "#recipe_path" do
    it "returns a string" do
      expect(unix_update_omnibus.recipe_path).to be_a(String)
    end
  end

  describe "#tmp_cookbook_path" do
    it "returns a string" do
      expect(unix_update_omnibus.tmp_cookbook_path).to be_a(String)
    end
  end

  describe "#tmp_cookbook" do
    it "returns a string" do
      expect(unix_update_omnibus.tmp_cookbook).to be_a(String)
    end
  end

  describe "#chef_solo_command" do
    it "returns a string" do
      expect(unix_update_omnibus.chef_solo_command).to be_a(String)
    end

    it "calls chef-solo" do
      expect(unix_update_omnibus.chef_solo_command).to start_with("chef-solo")
    end
  end

  describe "#chef_apply_command" do
    it "returns a string" do
      expect(unix_update_omnibus.chef_apply_command).to be_a(String)
    end

    it "calls chef-apply" do
      expect(unix_update_omnibus.chef_apply_command).to start_with("chef-apply")
    end
  end
end
