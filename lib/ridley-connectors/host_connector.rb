module  Ridley
  module HostConnector
    class Base
      include Celluloid
      include Ridley::Logging

      PORT_CHECK_TIMEOUT = 3
      RETRY_COUNT = 3
      CONNECTOR_PORT_ERRORS = [Errno::ETIMEDOUT,
                               Timeout::Error,
                               SocketError, 
                               Errno::ECONNREFUSED,
                               Errno::EHOSTUNREACH,
                               Errno::EADDRNOTAVAIL,
                               Resolv::ResolvError]

      if Buff::RubyEngine.jruby?
        CONNECTOR_PORT_ERRORS << Java::JavaNet::ConnectException
      end

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
      # @param [Float] timeout ({PORT_CHECK_TIMEOUT})
      #   the number of seconds to wait
      # @param [Int] retries ({RETRY_COUNT})
      #   the number of times to retry the connection before counting it unavailable
      #
      # @return [Boolean]
      def port_open?(host, port, timeout = PORT_CHECK_TIMEOUT, retries = RETRY_COUNT)
        @retry_count = retries
        begin
          defer {
            connectable?(host, port, timeout || PORT_CHECK_TIMEOUT)
          }
        rescue *CONNECTOR_PORT_ERRORS => ex
          @retry_count -= 1
          if @retry_count > 0
            log.info { "Retrying connector_port_open? on '#{host}' #{port} due to: #{ex.class}" }
            retry
          end
          false
        end
      end

      # Check if a port on a host is able to be connected, failing if the timeout transpires.
      #
      # @param [String] host
      #   the host to attempt to connect to
      # @param [Fixnum] port
      #   the port to attempt to connect on
      # @param [Fixnum] timeout ({PORT_CHECK_TIMEOUT})
      # 
      # @return [Boolean]
      def connectable?(host, port, timeout = PORT_CHECK_TIMEOUT)
        addr = Socket.getaddrinfo(host, nil)
        sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])
        socket = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        success = false
        begin
          socket.connect_nonblock(sockaddr)
          success = true
        rescue ::IO::WaitWritable
          if ::IO.select(nil, [socket], nil, timeout || PORT_CHECK_TIMEOUT)
            begin
              socket.connect_nonblock(sockaddr)
              success = true
            rescue Errno::EISCONN
              success = true
            rescue
              begin
                socket.close
              rescue Errno::EBADF
                # socket is not open
              end
            end
          else
            socket.close
          end
        end
        success
      end

    end

    require_relative 'host_connector/response'
    require_relative 'host_connector/ssh'
    require_relative 'host_connector/winrm'
  end
end
