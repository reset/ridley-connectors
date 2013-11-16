module Ridley
  class Client
    attr_accessor :ssh
    attr_accessor :winrm

    # @option options [String] :server_url
    #   URL to the Chef API
    # @option options [String] :client_name
    #   name of the client used to authenticate with the Chef API
    # @option options [String] :client_key
    #   filepath to the client's private key used to authenticate with the Chef API
    # @option options [String] :validator_client (nil)
    # @option options [String] :validator_path (nil)
    # @option options [String] :encrypted_data_bag_secret_path (nil)
    # @option options [Hash] :ssh (Hash.new)
    #   * :user (String) a shell user that will login to each node and perform the bootstrap command on (required)
    #   * :password (String) the password for the shell user that will perform the bootstrap
    #   * :keys (Array, String) an array of keys (or a single key) to authenticate the ssh user with instead of a password
    #   * :timeout (Float) [5.0] timeout value for SSH bootstrap
    #   * :sudo (Boolean) [true] bootstrap with sudo
    # @option options [Hash] :winrm (Hash.new)
    #   * :user (String) a user that will login to each node and perform the bootstrap command on (required)
    #   * :password (String) the password for the user that will perform the bootstrap
    #   * :port (Fixnum) the winrm port to connect on the node the bootstrap will be performed on (5985)
    # @option  options [String] :chef_version
    #   the version of Chef to use when bootstrapping
    # @option options [Hash] :params
    #   URI query unencoded key/value pairs
    # @option options [Hash] :headers
    #   unencoded HTTP header key/value pairs
    # @option options [Hash] :request
    #   request options
    # @option options [Hash] :ssl
    #   * :verify (Boolean) [true] set to false to disable SSL verification
    # @option options [URI, String, Hash] :proxy
    #   URI, String, or Hash of HTTP proxy options
    # @option options [Integer] :pool_size (4)
    #   size of the connection pool
    #
    # @raise [Errors::ClientKeyFileNotFoundOrInvalid] if the option for :client_key does not contain
    #   a file path pointing to a readable client key, or is a string containing a valid key
    def initialize(options = {})
      super
      @options = options.reverse_merge(
        ssh: Hash.new,
        winrm: Hash.new,
      ).deep_symbolize_keys

      @ssh              = @options[:ssh]
      @winrm            = @options[:winrm]
    end    
  end
end