module Ridley
  module CommandContext
    # Context class for generating an upgrade command for an Omnibus Chef installation on Unix based OSes
    class UnixUpdateOmnibus < CommandContext::Unix
      template_file 'unix_update_omnibus'

      # @return [String]
      attr_reader :chef_version

      # @return [Boolean]
      attr_reader :prerelease

      # @return [String]
      attr_reader :direct_url

      def initialize(options = {})
        super(options)
        options = options.reverse_merge(chef_version: "latest", prerelease: false)
        @chef_version = options[:chef_version]
        @prerelease = options[:prerelease]
        @direct_url = options[:direct_url]
      end

      def temp_path
        "/tmp"
      end
    end
  end
end
