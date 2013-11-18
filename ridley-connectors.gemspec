# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.authors       = ["Jamie Winsor", "Kyle Allan"]
  s.email         = ["jamie@vialstudios.com", "kallan@riotgames.com"]
  s.description   = %q{A Connector API for talking to nodes managed by Chef}
  s.summary       = s.description
  s.homepage      = "https://github.com/RiotGames/ridley-connectors"
  s.license       = "Apache 2.0"

  s.files         = `git ls-files`.split($\)
  s.executables   = Array.new
  s.test_files    = s.files.grep(%r{^(spec)/})
  s.name          = "ridley-connectors"
  s.require_paths = ["lib"]
  s.version       = "0.0.1"
  s.required_ruby_version = ">= 1.9.1"

  s.add_dependency 'celluloid', '~> 0.15'
  s.add_dependency 'celluloid-io', '~> 0.15'
  s.add_dependency 'net-ssh'
  s.add_dependency 'ridley', '~> 1.7.1'
  s.add_dependency 'winrm', '~> 1.1.0'
end
