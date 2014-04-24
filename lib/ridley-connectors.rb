require 'celluloid'
require 'celluloid/io'
require 'ridley'

module Ridley
  module Connectors
    class << self

      # @return [Pathname]
      def root
        @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
      end

      # @return [Pathname]
      def scripts
        root.join('scripts')
      end

      # @return [Pathname]
      def bootstrappers
        root.join('bootstrappers')
      end
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
