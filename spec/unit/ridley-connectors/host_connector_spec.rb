require 'spec_helper'

describe Ridley::HostConnector::Base do
  subject { Class.new(Ridley::HostConnector::Base).new }

  let(:host) { double('host') }
  let(:options) { Hash.new }

  describe "#run" do
    let(:command) { double('command') }

    it "raises a RuntimeError" do
      expect { subject.run(host, command, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#bootstrap" do
    it "raises a RuntimeError" do
      expect { subject.bootstrap(host, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#chef_client" do
    it "raises a RuntimeError" do
      expect { subject.chef_client(host, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#put_secret" do
    let(:secret) { double('secret') }

    it "raises a RuntimeError" do
      expect { subject.put_secret(host, secret, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#ruby_script" do
    let(:command_lines) { double('command-lines') }

    it "raises a RuntimeError" do
      expect { subject.ruby_script(host, command_lines, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#uninstall_chef" do
    it "raises a RuntimeError" do
      expect { subject.uninstall_chef(host, options) }.to raise_error(RuntimeError)
    end
  end

  describe "#connectable?" do
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
            raise WaitWritableError.new
          end
          raise Errno::EISCONN.new
        end
      end

      it "should return true when a connection is initiated" do
        ::IO.stub(:select).and_return ["an array!"]

        expect(subject.send(:connectable?, host, port)).to be true
      end

      it "should return true when a connection is initiated and an explicit nil is passed as the timeout" do
        ::IO.stub(:select).with(anything, anything, anything, Ridley::HostConnector::Base::PORT_CHECK_TIMEOUT).and_return ["an array!"]

        expect(subject.send(:connectable?, host, port, nil)).to be true
      end

      it "should return false when select times out" do
        ::IO.stub(:select).and_return nil

        expect(subject.send(:connectable?, host, port)).to be false
      end

      it "should return true when the connection does not have to wait" do
        Socket.any_instance.stub(:connect_nonblock).and_return 0

        expect(subject.send(:connectable?, host, port)).to be true
      end
    end

    Ridley::HostConnector::Base::CONNECTOR_PORT_ERRORS.each do |error|
      context "when the target causes #{error}" do
        before do
          calls = 0
          Socket.any_instance.stub(:connect_nonblock).and_return do
            calls += 1
            if calls == 1
              raise WaitWritableError.new
            end
            raise error.new
          end

          ::IO.stub(:select).and_return []
        end

        context "should return false" do
          it "" do
            expect(subject.send(:connectable?, host, port)).to be false
          end

          it "when the socket close throws EBAFD" do
            Socket.any_instance.stub(:close).and_return { raise Errno::EBADF.new }

            expect(subject.send(:connectable?, host, port)).to be false
          end
        end
      end
    end
  end
end
