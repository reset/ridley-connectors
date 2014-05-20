require 'spec_helper'

describe Ridley::CommandContext::UnixUninstall do
  let(:unix_uninstall) { described_class.new }

  describe "::new" do
    context "when skip_chef is not provided" do
      it "sets skip_chef to false" do
        expect(unix_uninstall.skip_chef).to be_false
      end
    end
  end

  describe "#command" do
    it "returns a string" do
      expect(unix_uninstall.command).to be_a(String)
    end
  end

  describe "#config_directory" do
    it "returns a string" do
      expect(unix_uninstall.config_directory).to be_a(String)
    end
  end

  describe "#data_directory" do
    it "returns a string" do
      expect(unix_uninstall.data_directory).to be_a(String)
    end
  end

  describe "#install_directory" do
    it "returns a string" do
      expect(unix_uninstall.install_directory).to be_a(String)
    end
  end
end
