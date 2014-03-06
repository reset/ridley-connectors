module Ridley
  module HostConnector
    class Base
      include Celluloid
      include Ridley::Logging

      PORT_CHECK_TIMEOUT = 3

      # Execute a shell command on a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [String] command
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def run(host, command, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Bootstrap a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def bootstrap(host, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Perform a chef client run on a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def chef_client(host, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Write your encrypted data bag secret on a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [String] secret
      #   your organization's encrypted data bag secret
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def put_secret(host, secret, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Execute line(s) of Ruby code on a node using Chef's embedded Ruby
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [Array<String>] command_lines
      #   An Array of lines of the command to be executed
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def ruby_script(host, command_lines, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Uninstall Chef from a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [Hash] options
      #
      # @return [HostConnector::Response]
      def uninstall_chef(host, options = {})
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      def connector_port_open?
        raise RuntimeError, "abstract function: must be implemented on includer"
      end

      # Checks to see if the given port is open for TCP connections
      # on the given host.
      #
      # @param [String] host
      #   the host to attempt to connect to
      # @param [Fixnum] port
      #   the port to attempt to connect on
      # @param [Float] wait_time ({PORT_CHECK_TIMEOUT})
      #   the number of seconds to wait
      #
      # @return [Boolean]
      def port_open?(host, port, wait_time = nil)
        defer {
          Timeout.timeout(wait_time || PORT_CHECK_TIMEOUT) { Celluloid::IO::TCPSocket.new(host, port).close; true }
        }
      rescue Errno::ETIMEDOUT, Timeout::Error, SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EADDRNOTAVAIL => ex
        false
      end

    end

    require_relative 'host_connector/response'
    require_relative 'host_connector/ssh'
    require_relative 'host_connector/winrm'
  end
end
