module Ridley
  module CommandContext
    # Context class for generating an upgrade command for an Omnibus Chef installation on Unix based OSes
    class WindowsUpdateOmnibus < CommandContext::Windows
      template_file 'windows_update_omnibus'

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

      def update_dir
        "C:\\chef\\update"
      end      

      def recipe_path
        "#{update_dir}\\default.rb"
      end

      def tmp_cookbook_path
        "#{update_dir}\\cookbooks\\upgrade_omnibus"
      end

      def tmp_recipes_path
        "#{tmp_cookbook_path}\\recipes"
      end

      def upgrade_solo_rb_path
        "#{update_dir}\\upgrade_solo.rb"
      end

      def chef_solo_command
        "chef-solo -c #{upgrade_solo_rb_path} -o upgrade_omnibus"
      end

      def chef_apply_command
        "chef-apply #{recipe_path}"
      end

      def recipe_code
        code = <<-RECIPE_CODE
chef_version = '#{chef_version}'
prerelease = #{prerelease}

platform = node[:platform]
case node[:platform_version]
when "6.1.7601"
  platform_version = "2008r2"
end
machine = node[:kernel][:machine]
nightlies = false

url = 'http://www.opscode.com/chef/download'
url_args = [ "p=\#{platform}", "pv=\#{platform_version}", "m=\#{machine}", "v=\#{chef_version}", "prerelease=\#{prerelease}", "nightlies=\#{nightlies}" ]

composed_url = "\#{url}?\#{url_args.join '&'}"

#{direct_url.nil? ? "full_url = composed_url" : "full_url = \"#{direct_url}\""}
request = Chef::REST::RESTRequest.new(:head, URI.parse(full_url), nil)
result = request.call

if result.kind_of?(Net::HTTPRedirection)
  full_url = result['location']
end

file_name = ::File.basename(full_url)
file_download_path = "C:\\\\chef\\\\update\\\\\#{file_name}"

remote_file file_download_path do
  source full_url
  backup false
  action :create_if_missing
end

file_extension = ::File.extname(file_name)

execute "Install the Omnibus package: \#{file_download_path}" do
  case file_extension
  when '.msi'
    command "msiexec /qb /i \#{file_download_path}"
  else
    raise 'Unknown package type encountered!'
  end
end
RECIPE_CODE
        escape_and_echo(code)
      end

      def escape_and_echo(file_contents)
        file_contents.gsub(/^(.*)$/, 'echo.\1').gsub(/([(<|>)^])/, '^\1')
      end
    end
  end
end
