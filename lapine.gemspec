# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lapine/version'

Gem::Specification.new do |spec|
  spec.name          = 'lapine'
  spec.version       = Lapine::VERSION
  spec.authors       = ['Eric Saxby', 'Matt Camuto']
  spec.email         = ['dev@wanelo.com']
  spec.summary       = %q{Talk to rabbits}
  spec.description   = %q{Talk to rabbits}
  spec.homepage      = 'https://github.com/wanelo/lapine'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'amqp'
  spec.add_dependency 'bunny'
  spec.add_dependency 'environmenter', '~> 0.1'
  spec.add_dependency 'middlewear', '~> 0.1'
  spec.add_dependency 'mixlib-cli'
  spec.add_dependency 'oj'
  spec.add_dependency 'ruby-usdt', '>= 0.2.2'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'em-spec'
end
