# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/domain/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-domain'
  spec.version       = Rack::Domain::VERSION
  spec.authors       = ['Andrea Leopardi']
  spec.email         = 'an.leopardi@gmail.com'
  spec.homepage      = 'https://github.com/whatyouhide/rack-domain'
  spec.license       = 'MIT'
  spec.summary       = <<-SUMMARY
    Rack middleware for dispatching Rack apps based on the domain'
  SUMMARY
  spec.description   = <<-DESCRIPTION
    This Rack middleware allows you to run specific apps when the request
    domain matches a given filter. The filter can be provided in a number of
    ways, for example as a regex or as a string.
  DESCRIPTION

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rack', '>= 1.5'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'minitest-reporters', '~> 1'
end
