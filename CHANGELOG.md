## v.1.6.0
* [#14](https://github.com/RiotGames/ridley-connectors/pull/14) Create
  a pool of WinRM / SSH actors, configurable with options(:connector\_pool\_size)

## v.1.5.0
* [#11](https://github.com/RiotGames/ridley-connectors/pull/11) use -E on sudo to preserve the environment

## v.1.2.1

* [#8](https://github.com/RiotGames/ridley-connectors/pull/8) Add a flag to execute Ruby scripts on Windows machines using a batch file
* [#9](https://github.com/RiotGames/ridley-connectors/pull/9) Fix a bug where a nil value for SSH or WinRM config would cause a NoMethodError

## v.1.2.0

* Bumping internal dependency on Ridley to at least 2.4.2

## v.1.1.0

* [#2](https://github.com/RiotGames/ridley-connectors/pull/2) Copying an encrypted data bag should not expose the secret

## v.1.0.1

* [#3](https://github.com/RiotGames/ridley-connectors/pull/3) Fix the broken Ridley::Client

## v.1.0.0

* [Ridley #227](https://github.com/RiotGames/ridley/pull/227) Move code out of Ridley and into its own gem
  * See the [Ridley 2.0.0 Changelog](https://github.com/RiotGames/ridley/blob/v2.0.0/CHANGELOG.md) for more details.
