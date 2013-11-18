require 'bundler'
require 'rubygems'
require 'spork'
require 'buff/ruby_engine'

def setup_rspec
  require 'rspec'
  require 'webmock/rspec'

  Dir[File.join(File.expand_path("../../spec/support/**/*.rb", __FILE__))].each { |f| require f }

  RSpec.configure do |config|
    config.include Ridley::SpecHelpers

    config.before(:suite) do
      WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true)
    end

    config.before(:all) { Ridley.logger = Celluloid.logger = nil }

    config.before(:each) do
      Celluloid.shutdown
      Celluloid.boot
    end
  end
end

if Buff::RubyEngine.mri? && ENV['CI'] != 'true'
  require 'spork'

  Spork.prefork do
    setup_rspec
  end

  Spork.each_run do
    require 'ridley-connectors'
  end
else
  require 'ridley-connectors'
  setup_rspec
end
