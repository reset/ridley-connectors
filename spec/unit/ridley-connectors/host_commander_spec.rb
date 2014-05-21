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
        subject.send(:winrm).stub(:port_open?).and_return(false)
        subject.send(:ssh).stub(:port_open?).and_return(true)
      end

      it "sends a #run message to the ssh host connector" do
        subject.send(:ssh).should_receive(:run).with(host, command, options)
        subject.run(host, command, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        subject.send(:ssh).stub(:port_open?).and_return(false)
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
        subject.send(:winrm).stub(:port_open?).and_return(false)
        subject.send(:ssh).stub(:port_open?).and_return(true)
      end

      it "sends a #bootstrap message to the ssh host connector" do
        subject.send(:ssh).should_receive(:bootstrap).with(host, options)

        subject.bootstrap(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        subject.send(:ssh).stub(:port_open?).and_return(false)
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
        subject.send(:winrm).stub(:port_open?).and_return(false)
        subject.send(:ssh).stub(:port_open?).and_return(true)
      end

      it "sends a #chef_client message to the ssh host connector" do
        subject.send(:ssh).should_receive(:chef_client).with(host, options)

        subject.chef_client(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        subject.send(:ssh).stub(:port_open?).and_return(false)
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
        subject.send(:winrm).stub(:port_open?).and_return(false)
        subject.send(:ssh).stub(:port_open?).and_return(true)
      end

      it "sends a #put_secret message to the ssh host connector" do
        subject.send(:ssh).should_receive(:put_secret).with(host, secret, options)

        subject.put_secret(host, secret, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        subject.send(:ssh).stub(:port_open?).and_return(false)
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
        subject.send(:winrm).stub(:port_open?).and_return(false)
        subject.send(:ssh).stub(:port_open?).and_return(true)
      end

      it "sends a #ruby_script message to the ssh host connector" do
        subject.send(:ssh).should_receive(:ruby_script).with(host, command_lines, options)

        subject.ruby_script(host, command_lines, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        subject.send(:ssh).stub(:port_open?).and_return(false)
      end

      it "sends a #ruby_script message to the ssh host connector" do
        subject.send(:winrm).should_receive(:ruby_script).with(host, command_lines, options)

        subject.ruby_script(host, command_lines, options)
      end
    end
  end

  describe "#connector_for" do
    let(:options) do
      { ssh: { port: 22, timeout: 3 }, winrm: { port: 5985, timeout: 3 }, retries: 3 }
    end

    context "when port_open? experiences an error" do
      let(:socket) { double(close: true) }

      it "executes retry logic" do
        @times_called = 0
        subject.send(:winrm).should_receive(:connectable?).twice.and_return do
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
      subject.send(:winrm).stub(:port_open?).and_return(true)
      expect(subject.connector_for(host).class).to eq(Ridley::HostConnector::WinRM)
    end
    
    it "should return ssh if winrm is closed" do
      subject.send(:winrm).stub(:port_open?).and_return(false)
      subject.send(:ssh).stub(:port_open?).and_return(true)
      expect(subject.connector_for(host).class).to eq(Ridley::HostConnector::SSH)
    end

    context "when a connector of winrm is given" do
      let(:connector_options) { options.merge(connector: "winrm") }
      let(:winrm) { double }

      it "should return winrm if winrm is open" do
        subject.send(:winrm).stub(:port_open?).and_return(true)
        expect(subject.connector_for(host, options).class).to eql(Ridley::HostConnector::WinRM)
      end

      it "should return nil if winrm is closed" do
        subject.stub(:port_open?).and_return(false)
        expect(subject.connector_for(host, connector_options)).to be_nil
      end
    end

    context "when a connector of ssh is given" do
      let(:connector_options) { options.merge(connector: "ssh") }

      it "should return ssh if ssh is open" do
        subject.send(:ssh).stub(:port_open?).and_return(true)
        subject.send(:winrm).should_not_receive(:port_open?)
        expect(subject.connector_for(host, connector_options).class).to eql(Ridley::HostConnector::SSH)
      end

      it "should return nil if ssh is closed" do
        subject.send(:ssh).stub(:port_open?).and_return(false)
        subject.send(:winrm).should_not_receive(:port_open?)
        expect(subject.connector_for(host, connector_options)).to be_nil
      end
    end

    context "when an unknown connector is given" do
      let(:connector_options) { options.merge(connector: "foo") }

      it "should try both connectors" do
        [:winrm, :ssh].each { |c| subject.send(c).should_receive(:port_open?) }
        subject.connector_for(host, connector_options)
      end
    end
  end
end
