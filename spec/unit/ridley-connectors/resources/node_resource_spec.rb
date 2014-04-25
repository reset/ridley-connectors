require 'spec_helper'

describe Ridley::NodeResource do
  let(:host) { "33.33.33.10" }
  let(:host_commander) { double('host-commander') }
  let(:options) do
    {
      server_url: double('server_url'),
      validator_path: double('validator_path'),
      validator_client: double('validator_client'),
      encrypted_data_bag_secret: double('encrypted_data_bag_secret'),
      ssh: double('ssh'),
      winrm: double('winrm'),
      chef_version: double('chef_version'),
      connector: nil
    }
  end

  let(:instance) do
    inst = described_class.new(double, options)
    inst.stub(host_commander: host_commander)
    inst
  end

  describe "#bootstrap" do
    let(:bootstrap_options) { options.delete(:connector); options }

    it "sends the message #bootstrap to the instance's host_commander" do
      host_commander.should_receive(:bootstrap).with(host, bootstrap_options)
      instance.bootstrap(host)
    end

    it "passes pre-configured options to #bootstrap" do
      host_commander.should_receive(:bootstrap).with(host, bootstrap_options)
      instance.bootstrap(host)
    end
  end

  describe "#chef_run" do
    it "sends the message #chef_client to the instance's host_commander" do
      host_commander.should_receive(:chef_client).with(host, ssh: instance.ssh, winrm: instance.winrm, connector: nil)
      instance.chef_run(host, options)
    end
  end

  describe "#put_secret" do
    let(:secret) { options[:encrypted_data_bag_secret] }

    it "sends the message #put_secret to the instance's host_commander" do
      host_commander.should_receive(:put_secret).with(host, secret, options.slice(:ssh, :winrm, :connector))
      instance.put_secret(host, options)
    end
  end

  describe "#ruby_script" do
    let(:command_lines) { ["puts 'hello'", "puts 'there'"] }

    it "sends the message #ruby_script to the instance's host_commander" do
      host_commander.should_receive(:ruby_script).with(host, command_lines, ssh: instance.ssh, winrm: instance.winrm, connector: nil)
      instance.ruby_script(host, command_lines, options)
    end
  end

  describe "#run" do
    let(:command) { "echo 'hello winrm_connectorld'" }

    it "sends the message #run to the instance's host_commander" do
      host_commander.should_receive(:run).with(host, command, ssh: instance.ssh, winrm: instance.winrm, connector: nil)
      instance.run(host, command, options)
    end
  end

  describe "#platform_specific_run" do
    let(:ssh_command) { "hostname -f" }
    let(:winrm_command) { "echo %COMPUTERNAME%" }
    let(:ssh_connector) { Ridley::HostConnector::SSH.new }
    let(:winrm_connector) { Ridley::HostConnector::WinRM.new }
    let(:unsupported_connector) { Object.new }

    describe "expecting the ssh connector" do
      before do
        host_commander.stub(:connector_for).and_return ssh_connector
      end
      it "sends the ssh command" do
        instance.should_receive(:run).with(host, ssh_command)
        instance.platform_specific_run(host, ssh: ssh_command, winrm: winrm_command)
      end

      it "raises an error if no command is provided for the ssh connector when the ssh connector is used" do
        expect {
          instance.platform_specific_run(host, winrm: winrm_command)
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end

      it "raises an error if an empty command is provided for the ssh connector when the ssh connector is used" do
        expect {
          instance.platform_specific_run(host, ssh: "", winrm: winrm_command)
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end

      it "raises an error if a nil command is provided for the ssh connector when the ssh connector is used" do
        expect {
          instance.platform_specific_run(host, ssh: nil, winrm: winrm_command)
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end
    end

    describe "expecting the winrm connector" do
      before do
        host_commander.stub(:connector_for).and_return winrm_connector
      end
      it "sends the ssh command if the connector is winrm" do
        instance.should_receive(:run).with(host, winrm_command)
        instance.platform_specific_run(host, ssh: ssh_command, winrm: winrm_command)
      end

      it "raises an error if no command is provided for the winrm connector when the winrm connector is used" do
        expect {
          instance.platform_specific_run(host, ssh: ssh_command)
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end

      it "raises an error if an empty is provided for the winrm connector when the winrm connector is used" do
        expect {
          instance.platform_specific_run(host, ssh: ssh_command, winrm: "")
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end

      it "raises a nil command is provided for the winrm connector when the winrm connector is used" do
        expect {
          instance.platform_specific_run(host, ssh: ssh_command, winrm: nil)
        }.to raise_error(Ridley::Errors::CommandNotProvided)
      end
    end

    it "raises a RuntimeError if an unsupported connector is used" do
      host_commander.stub(:connector_for).and_return unsupported_connector
      expect {
        instance.platform_specific_run(host, ssh: ssh_command, winrm: winrm_command)
      }.to raise_error(RuntimeError)
    end
  end  
end
