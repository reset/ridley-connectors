require 'ridley-connectors'

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

setup_rspec
