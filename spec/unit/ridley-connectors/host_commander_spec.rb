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
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      end

      it "sends a #run message to the ssh host connector" do
        expect(subject.send(:ssh)).to receive(:send).with(:run, host, command, options)
        subject.run(host, command, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
      end

      it "sends a #run message to the ssh host connector" do
        expect(subject.send(:winrm)).to receive(:send).with(:run, host, command, options)
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
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      end

      it "sends a #bootstrap message to the ssh host connector" do
        expect(subject.send(:ssh)).to receive(:bootstrap).with(host, options)

        subject.bootstrap(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
      end

      it "sends a #bootstrap message to the winrm host connector" do
        expect(subject.send(:winrm)).to receive(:bootstrap).with(host, options)

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
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      end

      it "sends a #chef_client message to the ssh host connector" do
        expect(subject.send(:ssh)).to receive(:chef_client).with(host, options)

        subject.chef_client(host, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
      end

      it "sends a #chef_client message to the ssh host connector" do
        expect(subject.send(:winrm)).to receive(:chef_client).with(host, options)

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
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      end

      it "sends a #put_secret message to the ssh host connector" do
        expect(subject.send(:ssh)).to receive(:put_secret).with(host, secret, options)

        subject.put_secret(host, secret, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
      end

      it "sends a #put_secret message to the ssh host connector" do
        expect(subject.send(:winrm)).to receive(:put_secret).with(host, secret, options)

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
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      end

      it "sends a #ruby_script message to the ssh host connector" do
        expect(subject.send(:ssh)).to receive(:ruby_script).with(host, command_lines, options)

        subject.ruby_script(host, command_lines, options)
      end
    end

    context "when communicating to a windows node" do
      before do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
      end

      it "sends a #ruby_script message to the ssh host connector" do
        expect(subject.send(:winrm)).to receive(:ruby_script).with(host, command_lines, options)

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
        expect(subject.send(:winrm)).to receive(:connectable?).twice do
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

    it "returns winrm if winrm is open" do
      allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
      expect(subject.connector_for(host).class).to eq(Ridley::HostConnector::WinRM)
    end

    it "returns ssh if winrm is closed" do
      allow(subject.send(:winrm)).to receive(:connector_port_open?) { false }
      allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
      expect(subject.connector_for(host).class).to eq(Ridley::HostConnector::SSH)
    end

    context "when a connector of winrm is given" do
      let(:connector_options) { options.merge(connector: "winrm") }
      let(:winrm) { double }

      it "returns winrm if winrm is open" do
        allow(subject.send(:winrm)).to receive(:connector_port_open?) { true }
        expect(subject.connector_for(host, options).class).to eql(Ridley::HostConnector::WinRM)
      end

      it "returns nil if winrm is closed" do
        allow(subject).to receive(:connector_port_open?) { false }
        expect(subject.connector_for(host, connector_options)).to be_nil
      end
    end

    context "when a connector of ssh is given" do
      let(:connector_options) { options.merge(connector: "ssh") }

      it "returns ssh if ssh is open" do
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { true }
        expect(subject.send(:winrm)).not_to receive(:connector_port_open?)
        expect(subject.connector_for(host, connector_options).class).to eql(Ridley::HostConnector::SSH)
      end

      it "returns nil if ssh is closed" do
        allow(subject.send(:ssh)).to receive(:connector_port_open?) { false }
        expect(subject.send(:winrm)).not_to receive(:connector_port_open?)
        expect(subject.connector_for(host, connector_options)).to be_nil
      end
    end

    context "when an unknown connector is given" do
      let(:connector_options) { options.merge(connector: "foo") }

      it "tries both connectors" do
        [:winrm, :ssh].each { |c| expect(subject.send(c)).to receive(:connector_port_open?) }
        subject.connector_for(host, connector_options)
      end
    end
  end
end
