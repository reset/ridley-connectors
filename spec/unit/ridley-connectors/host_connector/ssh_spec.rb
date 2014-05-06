require 'spec_helper'

describe Ridley::HostConnector::SSH do
  subject { connector }
  let(:connector) { described_class.new }

  let(:host) { 'fake.riotgames.com' }
  let(:options) do
    {
      server_url: double('server_url'),
      validator_path: fixtures_path.join('my-fake.pem'),
      validator_client: double('validator_client'),
      encrypted_data_bag_secret: 'encrypted_data_bag_secret',
      ssh: Hash.new,
      chef_version: double('chef_version')
    }
  end

  describe "#bootstrap" do
    let(:bootstrap_context) { Ridley::BootstrapContext::Unix.new(options) }

    it "sends a #run message to self to bootstrap a node" do
      connector.should_receive(:run).with(host, anything, options)
      connector.bootstrap(host, options)
    end

    it "filters the whole command" do
      expect(Ridley::Logging.logger).to receive(:filter_param).with(bootstrap_context.boot_command)
      connector.bootstrap(host, options)
    end
  end

  describe "#chef_client" do
    it "sends a #run message to self to execute chef-client" do
      connector.should_receive(:run).with(host, "chef-client -l warn", options)
      connector.chef_client(host, options)
    end
  end

  describe "#put_secret" do
    let(:encrypted_data_bag_secret_path) { fixtures_path.join("encrypted_data_bag_secret").to_s }
    let(:secret) { File.read(encrypted_data_bag_secret_path).chomp }

    it "receives a run command with echo" do
      connector.should_receive(:run).with(host,
        "echo '#{secret}' > /etc/chef/encrypted_data_bag_secret; chmod 0600 /etc/chef/encrypted_data_bag_secret",
        options
      )
      connector.put_secret(host, secret, options)
    end

    it "filters the secret" do
      expect(Ridley::Logging.logger).to receive(:filter_param).with(secret)
      connector.put_secret(host, secret, options)
    end
  end

  describe "#ruby_script" do
    let(:command_lines) { ["puts 'hello'", "puts 'there'"] }

    it "receives a ruby call with the command" do
      connector.should_receive(:run).with(host,
        "#{described_class::EMBEDDED_RUBY_PATH} -e \"puts 'hello';puts 'there'\"",
        options
      )
      connector.ruby_script(host, command_lines, options)
    end
  end

  describe "#uninstall_chef" do
    let(:command) { "uninstall chef" }

    before do
      Ridley::CommandContext::UnixUninstall.stub(:command).and_return(command)
    end

    it "receives a run command to uninstall chef" do
      connector.should_receive(:run).with(host, command, options)

      connector.uninstall_chef(host, options)
    end
  end

  describe "#update_omnibus" do
    let(:command) { "update omnibus" }

    before do
      Ridley::CommandContext::UnixUpdateOmnibus.stub(:command).and_return(command)
    end

    it "receives a run command to update omnibus" do
      connector.should_receive(:run).with(host, command, options)

      connector.update_omnibus(host, options)
    end
  end
end
