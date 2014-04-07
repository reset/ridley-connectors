require 'spec_helper'

describe Ridley::CommandContext::Base do
  let(:command_context) { described_class.new }

  describe "ClassMethods" do
    describe "::template_file" do
      let(:template_file) { described_class.template_file(filename) }
      let(:filename) { "test" }

      context "when a filename is provided" do
        it "sets and returns a class variable" do
          expect(template_file).to be_a(Pathname)
          expect(template_file.to_path).to end_with("scripts/test.erb")
        end
      end
    end
  end

  describe "#command" do
    let(:command) { command_context.command }
    let(:template) { double(:evaluate => nil) }

    before do
      command_context.stub(:template).and_return(template)
    end

    it "attempts to evaluate the template" do
      command
      expect(template).to have_received(:evaluate)
    end
  end
end

describe Ridley::CommandContext::Unix do
  let(:unix) { described_class.new(options) }

  describe "#command" do
    context "when sudo is true" do
      let(:command) { unix.command }
      let(:template) { double(:evaluate => command_string) }
      let(:options) do
        {sudo: true}
      end
      let(:command_string) { "echo 'hi'" }

      before do
        unix.stub(:template).and_return(template)
      end

      it "prepends sudo to the command" do
        expect(command).to eql("sudo echo 'hi'")
      end
    end
  end
end
