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

      it "executes retry logic" do
        @times_called = 0
        subject.should_receive(:connectable?).twice.and_return do
          @times_called += 1
          if @times_called == 1
            raise Errno::ETIMEDOUT
          else
            socket
          end
        end

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

  describe "#connectable?", focus: true do
    let(:port) { 1234 }

    before do
      Socket
        .stub(:getaddrinfo)
        .with(host, nil)
        .and_return [["AF_INET", 0, "33.33.33.10", "33.33.33.10", 2, 2, 17], 
                     ["AF_INET", 0, "33.33.33.10", "33.33.33.10", 2, 1,  6]]
    end

    context "when the target is accessible" do
      before do
        calls = 0
        Socket.any_instance.stub(:connect_nonblock).and_return do
          calls += 1
          if calls == 1
            raise ::IO::EAGAINWaitWritable.new
          end
          raise Errno::EISCONN.new
        end
      end

      it "should return true when a connection is initiated" do
        ::IO.stub(:select).and_return ["an array!"]
        
        expect(subject.send(:connectable?, host, port)).to be_true
      end

      it "should return true when a connection is initiated and an explicit nil is passed as the timeout" do
        ::IO.stub(:select).with(anything, anything, anything, Ridley::HostCommander::PORT_CHECK_TIMEOUT).and_return ["an array!"]
        
        expect(subject.send(:connectable?, host, port, nil)).to be_true
      end

      it "should return false when select times out" do
        ::IO.stub(:select).and_return nil

        expect(subject.send(:connectable?, host, port)).to be_false
      end

      it "should return true when the connection does not have to wait" do
        Socket.any_instance.stub(:connect_nonblock).and_return 0
        
        expect(subject.send(:connectable?, host, port)).to be_true
      end
    end

    Ridley::HostCommander::CONNECTOR_PORT_ERRORS.each do |error|
      context "when the target causes #{error}" do
        before do
          calls = 0
          Socket.any_instance.stub(:connect_nonblock).and_return do
            calls += 1
            if calls == 1
              raise ::IO::EAGAINWaitWritable.new
            end
            raise error.new
          end

          ::IO.stub(:select).and_return []
        end

        context "should return false" do
          it "" do
            expect(subject.send(:connectable?, host, port)).to be_false
          end

          it "when the socket close throws EBAFD" do
            Socket.any_instance.stub(:close).and_return { raise Errno::EBADF.new }

            expect(subject.send(:connectable?, host, port)).to be_false
          end
        end
      end
    end
  end
end
