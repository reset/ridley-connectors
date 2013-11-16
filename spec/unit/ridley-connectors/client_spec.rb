require 'spec_helper'

describe Ridley::Client do
  let(:server_url) { "https://api.opscode.com" }
  let(:client_name) { "fake" }
  let(:client_key) { fixtures_path.join("my-fake.pem").to_s }
  let(:ssh) { {user: "fake", password: "password1", port: "222"} }
  let(:winrm) { {user: "fake", password: "password2", port: "5986"} }
  let(:config) do
    {
      server_url: server_url,
      client_name: client_name,
      client_key: client_key,
      ssh: ssh,
      winrm: winrm
    }
  end

  describe "ClassMethods" do
    describe "::initialize" do
      subject { described_class.new(options) }

      it "assigns a 'ssh' attribute from the given 'ssh' option" do
        described_class.new(config).ssh.should eql({user: "fake", password: "password1", port: "222"})
      end

      it "assigns a 'winrm' attribute from the given 'winrm' option" do
        described_class.new(config).winrm.should eql({user: "fake", password: "password2", port: "5986"})
      end      
    end
  end
end
