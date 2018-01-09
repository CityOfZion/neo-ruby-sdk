lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'neo/sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'neo-sdk'
  spec.version       = Neo::SDK::VERSION
  spec.authors       = ['Jason L Perry']
  spec.email         = ['jason@cityofzion.io']

  spec.summary       = 'Neo Ruby SDK'
  spec.description   = 'A Ruby SDK for creating smart contracts on the NEO blockchain.'
  spec.homepage      = 'https://github.com/CityOfZio/neo-ruby-sdk'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-autotest'
  spec.add_development_dependency 'minitest-ci'
  spec.add_development_dependency 'rake', '~> 12.0'
end
