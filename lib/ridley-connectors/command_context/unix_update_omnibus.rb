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

      def upgrade_solo_rb
        "/tmp/upgrade_solo.rb"
      end

      def upgrade_cookbook_path
        "/tmp/cookbooks/upgrade_omnibus/recipes/"
      end

      def chef_solo_command
        "chef-solo -c #{upgrade_solo_rb} -o upgrade_omnibus"
      end

      def recipe_name
        "default.rb"
      end

      def chef_apply_command
        "chef-apply #{File.join(temp_path, recipe_name)}"
      end
    end
  end
end
