require 'net/ssh'
require 'net/ssh/gateway'

module Ridley
  module HostConnector
    class SSH < HostConnector::Base
      DEFAULT_PORT       = 22
      EMBEDDED_RUBY_PATH = '/opt/chef/embedded/bin/ruby'.freeze

      # Execute a shell command on a node using ssh. If the gateway option is present then
      # execute the command through the gateway.
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [String] command
      #
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo
      #   * :gateway (String) user@host:port
      #
      # @return [HostConnector::Response]
      def run(host, command, options = {})
        options = options.reverse_merge(ssh: Hash.new)
        options[:ssh].reverse_merge!(port: DEFAULT_PORT, paranoid: false, sudo: false)

        command = "sudo -E #{command}" if options[:ssh][:sudo]

        Ridley::HostConnector::Response.new(host).tap do |response|
          begin
            log.info "Running SSH command: '#{command}' on: '#{host}' as: '#{options[:ssh][:user]}'"

            defer {
              ssh(host, options) do |ssh|
                ssh.open_channel do |channel|
                  if options[:sudo]
                    channel.request_pty do |channel, success|
                      unless success
                        raise "Could not aquire pty: A pty is required for running sudo commands."
                      end

                      channel_exec(channel, command, host, response)
                    end
                  else
                    channel_exec(channel, command, host, response)
                  end
                end
                ssh.loop
              end
            }
          rescue Net::SSH::AuthenticationFailed => ex
            response.exit_code = -1
            response.stderr    = "Authentication failure for user #{ex}"
          rescue Net::SSH::ConnectionTimeout, Timeout::Error
            response.exit_code = -1
            response.stderr    = "Connection timed out"
          rescue SocketError, Errno::EHOSTUNREACH
            response.exit_code = -1
            response.stderr    = "Host unreachable"
          rescue Errno::ECONNREFUSED
            response.exit_code = -1
            response.stderr    = "Connection refused"
          rescue Net::SSH::Exception => ex
            response.exit_code = -1
            response.stderr    = ex.inspect
          rescue => ex
            response.exit_code = -1
            response.stderr    = "An unknown error occurred: #{ex.class} - #{ex.message}"
          end

          case response.exit_code
          when 0
            log.info "Successfully ran SSH command on: '#{host}' as: '#{options[:ssh][:user]}'"
          when -1
            log.info "Failed to run SSH command on: '#{host}' as: '#{options[:ssh][:user]}'"
          else
            log.info "Successfully ran SSH command on: '#{host}' as: '#{options[:ssh][:user]}' but it failed"
          end
        end
      end

      # Bootstrap a node
      #
      # @param [String] host
      #   the host to perform the action on
      #
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo
      #
      # @return [HostConnector::Response]
      def bootstrap(host, options = {})
        options = options.reverse_merge(ssh: Hash.new)
        options[:ssh].reverse_merge!(sudo: true, timeout: 5.0)
        context = BootstrapContext::Unix.new(options)

        log.info "Bootstrapping host: #{host}"
        log.filter_param(context.boot_command)
        run(host, context.boot_command, options)
      end

      # Perform a chef client run on a node
      #
      # @param [String] host
      #   the host to perform the action on
      #
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo
      #
      # @return [HostConnector::Response]
      def chef_client(host, options = {})
        log_level = case log.level
          when 0
            "debug"
          when 1
            "info"
          when 2
            "warn"
          else
            "info"
          end
        run(host, "chef-client -l #{log_level}", options)
      end

      # Write your encrypted data bag secret on a node
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [String] secret
      #   your organization's encrypted data bag secret
      #
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo
      #
      # @return [HostConnector::Response]
      def put_secret(host, secret, options = {})
        log.filter_param(secret)
        cmd = "echo '#{secret}' > /etc/chef/encrypted_data_bag_secret; chmod 0600 /etc/chef/encrypted_data_bag_secret"
        run(host, cmd, options)
      end

      # Execute line(s) of Ruby code on a node using Chef's embedded Ruby
      #
      # @param [String] host
      #   the host to perform the action on
      # @param [Array<String>] command_lines
      #   An Array of lines of the command to be executed
      #
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo
      #
      # @return [HostConnector::Response]
      def ruby_script(host, command_lines, options = {})
        run(host, "#{EMBEDDED_RUBY_PATH} -e \"#{command_lines.join(';')}\"", options)
      end

      # Uninstall Chef from a node
      #
      # @param [String] host
      #   the host to perform the action on
      #
      # @option options [Boolena] :skip_chef (false)
      #   skip removal of the Chef package and the contents of the installation
      #   directory. Setting this to true will only remove any data and configurations
      #   generated by running Chef client.
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo (true)
      #
      # @return [HostConnector::Response]
      def uninstall_chef(host, options = {})
        options = options.reverse_merge(ssh: Hash.new)
        options[:ssh].reverse_merge!(sudo: true, timeout: 5.0)

        log.info "Uninstalling Chef from host: #{host}"
        run(host, CommandContext::UnixUninstall.command(options), options)
      end

      # Update a node's Omnibus installation of Chef
      #
      # @param [String] host
      #   the host to perform the action on
      #
      # @option options [String] :chef_version
      #   the version of Chef to install on the node
      # @option options [Boolean] :prerelease
      #   install a prerelease version of Chef
      # @option options [String] :direct_url
      #   a url pointing directly to a Chef package to install
      # @option options [Hash] :ssh
      #   * :user (String) a shell user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the shell user that will perform the bootstrap
      #   * :keys (Array, String) an array of key(s) to authenticate the ssh user with instead of a password
      #   * :timeout (Float) timeout value for SSH bootstrap (5.0)
      #   * :sudo (Boolean) run as sudo (true)
      # @option options [Hash] :winrm
      #   * :user (String) a user that will login to each node and perform the bootstrap command on
      #   * :password (String) the password for the user that will perform the bootstrap (required)
      #   * :port (Fixnum) the winrm port to connect on the node the bootstrap will be performed on (5985)
      #
      # @return [HostConnector::Response]
      def update_omnibus(host, options = {})
        options = options.reverse_merge(ssh: Hash.new)
        options[:ssh].reverse_merge!(sudo: true, timeout: 5.0)

        log.info "Updating Omnibus installation on host: #{host}"
        run(host, CommandContext::UnixUpdateOmnibus.command(options), options)
      end

      # Checks to see if the given port is open for TCP connections
      # on the given host. If a gateway is provided in the ssh
      # options, then return true if we can connect to the gateway host.
      # If no gateway config is found then just verify we can connect to
      # the destination host.
      #
      # @param [String] host
      #   the host to attempt to connect to
      # @option options [Hash] :ssh
      #   * :gateway (String) user@host:port
      #   * :timeout (Float) timeout value for SSH
      #   * :port (Fixnum) the SSH port
      # @return [Boolean]
      def connector_port_open?(host, options = {})
        options[:ssh]          ||= Hash.new
        options[:ssh][:port]   ||= HostConnector::SSH::DEFAULT_PORT

        if options[:ssh][:gateway]
          gw_host, gw_port, _ = gateway(options)
          log.info("Connecting to host '#{gw_host}' via SSH gateway over port '#{gw_port}'")
          port_open?(gw_host, gw_port, options[:ssh][:timeout])
        else
          port_open?(host, options[:ssh][:port], options[:ssh][:timeout])
        end
      end

      private

        def gateway(options)
          options[:ssh] ||= Hash.new

          if options[:ssh][:gateway]
            gw_host, gw_user = options[:ssh][:gateway].split("@").reverse
            gw_host, gw_port = gw_host.split(":")
            gw_port ||= HostConnector::SSH::DEFAULT_PORT
            [gw_host, gw_port, gw_user]
          else
            [nil, nil, nil]
          end
        end

        # Open an SSH connection either directly or through a gateway.
        def ssh(host, options, &block)
          if options[:ssh][:gateway]
            gw_host, gw_port, gw_user = gateway(options)
            gateway = Net::SSH::Gateway.new(gw_host, gw_user, {:port => gw_port})
            begin
              gateway.ssh(host, options[:ssh][:user], options[:ssh].slice(*Net::SSH::VALID_OPTIONS)) do |ssh|
                yield ssh
              end
            ensure
              gateway.shutdown!
            end
          else
            Net::SSH.start(host, options[:ssh][:user], options[:ssh].slice(*Net::SSH::VALID_OPTIONS)) do |ssh|
              yield ssh
            end
          end
        end

        def channel_exec(channel, command, host, response)
          channel.exec(command) do |ch, success|
            unless success
              raise "Channel execution failed while executing command #{command}"
            end

            channel.on_data do |ch, data|
              response.stdout += data
              log.info "[#{host}](SSH) #{data}" if data.present? and data != "\r\n"
            end

            channel.on_extended_data do |ch, type, data|
              response.stderr += data
              log.info "[#{host}](SSH) #{data}" if data.present? and data != "\r\n"
            end

            channel.on_request("exit-status") do |ch, data|
              response.exit_code = data.read_long
            end

            channel.on_request("exit-signal") do |ch, data|
              response.exit_signal = data.read_string
            end
          end
        end
    end
  end
end
