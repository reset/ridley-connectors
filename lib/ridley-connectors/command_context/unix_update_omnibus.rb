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

      # @return [String]
      def update_dir
        "/tmp"
      end

      # @return [String]
      def recipe_path
        File.join(update_dir, "default.rb")
      end

      # @return [String]
      def upgrade_solo_rb_path
        File.join(update_dir, "upgrade_solo.rb")
      end

      # @return [String]
      def tmp_cookbook_path
        File.join(update_dir, "cookbooks")
      end

      # @return [String]
      def tmp_cookbook
        File.join(tmp_cookbook_path, "upgrade_omnibus")
      end

      # @return [String]
      def chef_solo_command
        "chef-solo -c #{upgrade_solo_rb_path} -o upgrade_omnibus"
      end

      # @return [String]
      def chef_apply_command
        "chef-apply #{recipe_path}"
      end
    end
  end
end
