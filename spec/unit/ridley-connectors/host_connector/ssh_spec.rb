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

  describe "#run" do
    let(:ssh_user) { 'ssh_user' }

    context "when a gateway is given" do
      let(:gw_host) { "bar.com" }
      let(:gw_user) { "foo" }
      let(:gw_port) { "1234" }
      let(:gateway) { double(Net::SSH::Gateway) }

      before do
        Net::SSH::Gateway.stub(:new).with(gw_host, gw_user, {:port => gw_port}).and_return(gateway)
      end

      it "should connect to the gateway with Net::SSH::Gateway and then to the destination host via the gateway" do
        gateway.should_receive(:ssh).with(host, ssh_user, anything).ordered
        gateway.should_receive(:shutdown!).ordered
        subject.run(host, "some_command", ssh: { user: ssh_user, gateway: 'foo@bar.com:1234' })
      end
    end

    context "when a gateway is not given" do
      it "should use Net::SSH to connect to the destination host" do
        Net::SSH.should_receive(:start).with(host, ssh_user, {:paranoid=>false, :port=>"1234", :user=>"ssh_user"})
        subject.run(host, "some_command", ssh: { user: ssh_user, port: "1234" })
      end
    end
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
      connector.should_receive(:run).with(host, "chef-client", options)
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

  describe "#connector_port_open?" do
    context "when there are no ssh options specified" do
      it "should try to connect to the host on the defaul ssh port" do
        subject.should_receive(:port_open?).with(host, Ridley::HostConnector::SSH::DEFAULT_PORT, nil)
        subject.connector_port_open?(host, {})
      end
    end

    context "when the port is specified" do
      it "should try to connecto to the host on the given port" do
        subject.should_receive(:port_open?).with(host, 1234, nil)
        subject.connector_port_open?(host, ssh: {port: 1234} )
      end
    end

    context "when the gateway is given" do
      it "should try to connect to the gateway host" do
        subject.should_receive(:port_open?).with("bar.com", "1234", nil)
        subject.connector_port_open?(host, ssh: {gateway: 'foo@bar.com:1234'} )
      end

      it "should use the timeout from the ssh settings" do
        subject.should_receive(:port_open?).with("bar.com", "1234", 12)
        subject.connector_port_open?(host, ssh: {timeout: 12, gateway: 'foo@bar.com:1234'} )
      end
    end
  end

end
