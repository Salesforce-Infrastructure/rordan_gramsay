require_relative 'lib/rordan_gramsay/version'

Gem::Specification.new do |spec|
  spec.name          = RordanGramsay::GEM_NAME
  spec.version       = RordanGramsay::VERSION
  spec.authors       = ['David Alexander', 'Michael Tharpe']
  spec.email         = ['mc-infraautomation@salesforce.com']

  spec.summary       = %(Tools for automating development)
  spec.description   = %(Tools for automating development)
  spec.homepage      = 'https://github.com/Salesforce-Infrastructure/rordan_gramsay'
  spec.license       = 'BSDv3'

  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = [RordanGramsay::EXECUTABLE]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.3'

  spec.add_runtime_dependency 'berkshelf'
  spec.add_runtime_dependency 'chef'
  spec.add_runtime_dependency 'cookstyle', '~> 3.0'
  spec.add_runtime_dependency 'foodcritic', '~> 14.0'
  spec.add_runtime_dependency 'paint', '~> 2.0'
  spec.add_runtime_dependency 'rake', '>= 10.0.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'mdl'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'simplecov'
end
