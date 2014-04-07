module Ridley
  module Errors
    module ConnectorsError; end

    class HostConnectionError < RidleyError
      include ConnectorsError
    end

    class DNSResolvError < HostConnectionError
      include ConnectorsError
    end

    class BootstrapError < RidleyError; end
    class RemoteCommandError < RidleyError; end
    class RemoteScriptError < RemoteCommandError; end
    class CommandNotProvided < RemoteCommandError
      attr_reader :connector_type

      # @params [Symbol] connector_type
      def initialize(connector_type)
        @connector_type = connector_type
      end

      def to_s
        "No command provided in #{connector_type.inspect}, however the #{connector_type.inspect} connector was selected."
      end
    end
  end
end
