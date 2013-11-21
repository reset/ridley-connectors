require 'spec_helper'

describe Ridley::NodeObject do
  let(:resource) { double('resource') }
  let(:instance) { described_class.new(resource) }
  subject { instance }

  describe "#chef_run" do
    it "sends the message #chef_run to the resource with the public_hostname of this instance" do
      resource.should_receive(:chef_run).with(instance.public_hostname)
      subject.chef_run
    end
  end

  describe "#put_secret" do
    it "sends the message #put_secret to the resource with the public_hostname of this instance" do
      resource.should_receive(:put_secret).with(instance.public_hostname)

      subject.put_secret
    end
  end  
end
