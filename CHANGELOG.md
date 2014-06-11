## 2.3.1

* Fix installation problem on some Windows machines

## 2.3.0

* Dependency update

## 2.2.0

* [#27](https://github.com/RiotGames/ridley-connectors/pull/27) New upgrade_omnibus feature for updating a node's Omnibus installation of Chef

## 2.1.2

* [#25](https://github.com/RiotGames/ridley-connectors/pull/25) Fix an edge case in the connector_for logic from #22

## 2.1.1

* [#24](https://github.com/RiotGames/ridley-connectors/pull/24) Fix a bug with Timeout.rb unable to interrupt Socket connections (mostly JRuby)

## 2.1.0

* [#21](https://github.com/RiotGames/ridley-connectors/pull/21) Fix bootstrappers and pathing to files moved from Ridley
* [#22](https://github.com/RiotGames/ridley-connectors/pull/22) Added a new option to allow connector_for to pick a connector more intelligently

## 2.0.1

* [#18](https://github.com/RiotGames/ridley-connectors/pull/18) Move more connector-specific code out of ridley and into ridley-connectors
* [#19](https://github.com/RiotGames/ridley-connectors/pull/19) Add some extra logging to retrying connections to choose an appropriate connector
* [#20](https://github.com/RiotGames/ridley-connectors/pull/20) Handle HostCommander, WinRM, and SSH actor crashes better

## 2.0.0

* [#17](https://github.com/RiotGames/ridley-connectors/pull/17) Bump ridley dependency to 3.0.0

## 1.7.1

* [#16](https://github.com/RiotGames/ridley-connectors/pull/16) JRuby throws different exceptions when it can't connect to a node

## 1.7.0

* [#15](https://github.com/RiotGames/ridley-connectors/pull/15) Add retries to ssh and winrm connections

## 1.6.0
* [#14](https://github.com/RiotGames/ridley-connectors/pull/14) Create
  a pool of WinRM / SSH actors, configurable with options(:connector\_pool\_size)

## 1.5.0
* [#11](https://github.com/RiotGames/ridley-connectors/pull/11) use -E on sudo to preserve the environment

## 1.2.1

* [#8](https://github.com/RiotGames/ridley-connectors/pull/8) Add a flag to execute Ruby scripts on Windows machines using a batch file
* [#9](https://github.com/RiotGames/ridley-connectors/pull/9) Fix a bug where a nil value for SSH or WinRM config would cause a NoMethodError

## 1.2.0

* Bumping internal dependency on Ridley to at least 2.4.2

## 1.1.0

* [#2](https://github.com/RiotGames/ridley-connectors/pull/2) Copying an encrypted data bag should not expose the secret

## 1.0.1

* [#3](https://github.com/RiotGames/ridley-connectors/pull/3) Fix the broken Ridley::Client

## 1.0.0

* [Ridley #227](https://github.com/RiotGames/ridley/pull/227) Move code out of Ridley and into its own gem
  * See the [Ridley 2.0.0 Changelog](https://github.com/RiotGames/ridley/blob/v2.0.0/CHANGELOG.md) for more details.
