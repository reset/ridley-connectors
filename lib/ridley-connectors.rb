require 'celluloid'
require 'celluloid/io'
require 'ridley'

module Ridley
  class << self
    # @return [Pathname]
    def scripts
      root.join('scripts')
    end
  end

  require_relative 'ridley-connectors/client'
  require_relative 'ridley-connectors/bootstrap_context'
  require_relative 'ridley-connectors/command_context'
  require_relative 'ridley-connectors/host_commander'
  require_relative 'ridley-connectors/host_connector'
  require_relative 'ridley-connectors/chef_objects/node_object'
  require_relative 'ridley-connectors/resources/node_resource'
  require_relative 'ridley-connectors/errors'
end
