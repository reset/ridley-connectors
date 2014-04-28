require 'spec_helper'

describe Ridley::HostCommander do
  subject { described_class.new }
  let(:host) { "fake.riotgames.com" }

  describe "#run" do
    let(:command) { "ls" }
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when communicating to a unix node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(false)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(true)
      end

      it "sends a #run message to the ssh host connector" do
        subject.send(:ssh).should_receive(:run).with(host, command, options)
        subject.run(host, command, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(true)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(false)
      end

      it "sends a #run message to the ssh host connector" do
        subject.send(:winrm).should_receive(:run).with(host, command, options)

        subject.run(host, command, options)
      end
    end
  end

  describe "#bootstrap" do
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when communicating to a unix node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(false)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(true)
      end

      it "sends a #bootstrap message to the ssh host connector" do
        subject.send(:ssh).should_receive(:bootstrap).with(host, options)

        subject.bootstrap(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(true)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(false)
      end

      it "sends a #bootstrap message to the winrm host connector" do
        subject.send(:winrm).should_receive(:bootstrap).with(host, options)

        subject.bootstrap(host, options)
      end
    end
  end

  describe "#chef_client" do
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when communicating to a unix node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(false)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(true)
      end

      it "sends a #chef_client message to the ssh host connector" do
        subject.send(:ssh).should_receive(:chef_client).with(host, options)

        subject.chef_client(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(true)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(false)
      end

      it "sends a #chef_client message to the ssh host connector" do
        subject.send(:winrm).should_receive(:chef_client).with(host, options)

        subject.chef_client(host, options)
      end
    end
  end

  describe "#put_secret" do
    let(:secret) { "something_secret" }
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when communicating to a unix node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(false)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(true)
      end

      it "sends a #put_secret message to the ssh host connector" do
        subject.send(:ssh).should_receive(:put_secret).with(host, secret, options)

        subject.put_secret(host, secret, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(true)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(false)
      end

      it "sends a #put_secret message to the ssh host connector" do
        subject.send(:winrm).should_receive(:put_secret).with(host, secret, options)

        subject.put_secret(host, secret, options)
      end
    end
  end

  describe "#ruby_script" do
    let(:command_lines) { ["line one"] }
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when communicating to a unix node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(false)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(true)
      end

      it "sends a #ruby_script message to the ssh host connector" do
        subject.send(:ssh).should_receive(:ruby_script).with(host, command_lines, options)

        subject.ruby_script(host, command_lines, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.stub(:connector_port_open?).with(host, options[:winrm][:port], anything, anything).and_return(true)
        subject.stub(:connector_port_open?).with(host, options[:ssh][:port], anything, anything).and_return(false)
      end

      it "sends a #ruby_script message to the ssh host connector" do
        subject.send(:winrm).should_receive(:ruby_script).with(host, command_lines, options)

        subject.ruby_script(host, command_lines, options)
      end
    end
  end

  describe "#connector_for" do

    context "when connector_port_open? experiences an error" do
      let(:socket) { double(close: true) }


      before do
        @times_called = 0
        Celluloid::IO::TCPSocket.stub(:new).and_return do
          @times_called += 1
          if @times_called == 1
            raise Errno::ETIMEDOUT
          else
            socket
          end
        end
      end

      it "executes retry logic" do
        expect(Celluloid::IO::TCPSocket).to receive(:new).twice
        subject.connector_for(host)
      end
    end

    it "should return winrm if winrm is open" do
      subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything).and_return(true)
      subject.should_receive(:winrm)
      subject.connector_for(host)
    end
    
    it "should return ssh if winrm is closed" do
      subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything).and_return(false)
      subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::SSH::DEFAULT_PORT, anything, anything).and_return(true)
      subject.should_receive(:ssh)
      subject.connector_for(host)
    end

    it "should still set the default ports if an explicit nil is passed in" do
      subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything).and_return(true)
      subject.should_receive(:winrm)
      subject.connector_for(host, winrm: nil, ssh: nil)
    end

    context "when a connector of winrm is given" do
      let(:options) do
        { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3, connector: "winrm" }
      end
      let(:winrm) { double }

      it "should return winrm if winrm is open" do
        subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything).and_return(true)
        subject.stub(:winrm).and_return(winrm)
        expect(subject.connector_for(host, options)).to eql(winrm)
      end

      it "should return nil if winrm is closed" do
        subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything).and_return(false)
        expect(subject.connector_for(host, options)).to be_nil
      end
    end

    context "when a connector of ssh is given" do
      let(:options) do
        { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3, connector: "ssh" }
      end
      let(:ssh) { double }

      it "should return ssh if ssh is open" do
        subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::SSH::DEFAULT_PORT, anything, anything).and_return(true)
        subject.stub(:ssh).and_return(ssh)
        subject.should_not_receive(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything)
        expect(subject.connector_for(host, options)).to eql(ssh)
      end

      it "should return nil if ssh is closed" do
        subject.stub(:connector_port_open?).with(host, Ridley::HostConnector::SSH::DEFAULT_PORT, anything, anything).and_return(false)
        subject.should_not_receive(:connector_port_open?).with(host, Ridley::HostConnector::WinRM::DEFAULT_PORT, anything, anything)
        expect(subject.connector_for(host, options)).to be_nil
      end
    end
  end

  describe "#connector_port_open?" do
    let(:host) { "host.com" }
    let(:port) { 1234 }

    it "should return false if the port connection times out" do
      Thread.any_instance.stub(:alive?).and_return(true, false)
      NIO::Selector.any_instance.stub(:select)

      expect(subject.send(:connector_port_open?, host, port)).to be_false
    end

    it "should return true if the port connection is successful" do
      Celluloid::IO::TCPSocket.stub(:new).and_return nil
      expect(subject.send(:connector_port_open?, host, port)).to be_true
    end
    
    it "should return false if the port connection raises any error" do
      Celluloid::IO::TCPSocket.stub(:new).and_return { raise "any error" }
      expect(subject.send(:connector_port_open?, host, port)).to be_false
    end
  end
end
