# Ridley Connectors
[![Gem Version](https://badge.fury.io/rb/ridley-connectors.png)](http://badge.fury.io/rb/ridley-connectors)
[![Build Status](https://secure.travis-ci.org/RiotGames/ridley-connectors.png?branch=master)](http://travis-ci.org/RiotGames/ridley-connectors)
[![Dependency Status](https://gemnasium.com/RiotGames/ridley-connectors.png?travis)](https://gemnasium.com/RiotGames/ridley-connectors)

An extension on [Ridley](https://github.com/RiotGames/ridley) adding support for connecting and communicating with nodes in Chef.

Installation
------------
Add ridley-connectors to your `Gemfile`:

```ruby
gem 'ridley-connectors'
```

And run the `bundle` command to install. Alternatively, you can install the gem directly:

    $ gem install ridley-connectors

Usage
-----
You can use ridley-connectors just like using Ridley.

```ruby
require 'ridley'
```

### Creating a new Ridley client

```ruby
ridley = Ridley.new(
  server_url: "https://api.opscode.com/organizations/ridley",
  client_name: "me",
  client_key: "/Users/me/.chef/me.pem"
)
```

ridley-connectors exposes all the usual features of Ridley, but adds some sugar for interacting with nodes.

```ruby
ridley.node.bootstrap("hostname.to.bootstrap.com") # Bootstraps a hostname or IP
ridley.node.put_secret("hostname") # Puts your configured encrypted data bag secret onto a hostname or IP
ridley.node.chef_run("hostname") # Runs Chef on a hostname or IP

```
Node Resource
-------------

### Bootstrapping Unix nodes

```ruby
ridley = Ridley.new(
  server_url: "https://api.opscode.com",
  organization: "vialstudios",
  validator_client: "vialstudios-validator",
  validator_path: "/Users/reset/.chef/vialstudios-validator.pem",
  ssh: {
    user: "vagrant",
    password: "vagrant"
  }
)

ridley.node.bootstrap("33.33.33.10", "33.33.33.11")
```

### Bootstrapping Windows Nodes

Windows Nodes are bootstrapped using a combination of WinRM, Batch, and PowerShell. You will probably need to tweak some settings on your Windows servers to ensure the commands are successful.

#### WinRM Settings

1. Enable WinRM: `winrm quickconfig` and say Yes.
2. Set some WinRM settings to ensure that you don't get 401 Unauthorized responses and 500 Responses because of timeouts.

```
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service @{EnumerationTimeoutms="600000"}
winrm set winrm/config @{MaxTimeoutms="600000"}
winrm set winrm/config/client @{TrustedHosts="*"}
```

#### PowerShell Settings

1. You should also configure your PowerShell profile, so that PowerShell commands have a more lenient timeout period.

```
mkdir C:\Users\my_user\Documents\WindowsPowerShell
echo "$PSSessionOption = New-PSSessionOption -OpenTimeout 0 -CancelTimeout 0 -IdleTimeout 0 -OperationTimeout 0" > C:\Users\my_user\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

Verify the PowerShell settings by opening up the PowerShell Console and entering `$PSSessionOption` and ensure those values are set, and that there are no errors output.

The following links offer some information about configuring a machine's PowerShell settings:
- [PowerShell Profiles](http://technet.microsoft.com/en-us/library/ee692764.aspx)
- [The $PSSessionOptions Preference Variable](http://technet.microsoft.com/library/hh847796.aspx)
- [Creating a new PSSessionOption](http://technet.microsoft.com/en-us/library/hh849703.aspx)

You may also want to tweak your Windows boxes a bit more ex: turning UAC off, turning off the Windows Firewall.

Authors and Contributors
------------------------
- Jamie Winsor (<jamie@vialstudios.com>)
- Kyle Allan (<kallan@riotgames.com>)

Thank you to all of our [Contributors](https://github.com/RiotGames/ridley-connectors/graphs/contributors), testers, and users.
