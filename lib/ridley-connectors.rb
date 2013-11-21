require 'celluloid'
require 'celluloid/io'
require 'ridley'

module Ridley
  require_relative 'ridley-connectors/client'
  require_relative 'ridley-connectors/host_commander'
  require_relative 'ridley-connectors/host_connector'
  require_relative 'ridley-connectors/chef_objects/node_object'
  require_relative 'ridley-connectors/resources/node_resource'
end
