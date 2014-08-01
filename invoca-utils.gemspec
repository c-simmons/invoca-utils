# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'invoca/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "invoca-utils"
  spec.version       = Invoca::Utils::VERSION
  spec.authors       = ["Cary Penniman"]
  spec.email         = ["cpenniman@invoca.com"]
  spec.summary       = %q{A public collection of helpers used in multiple projects}
  spec.description   = %q{A public collection of helpers used in multiple projects}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "test-unit", "= 1.2.3"
  spec.add_development_dependency "rr", "=1.1.2"
  spec.add_development_dependency "shoulda", "= 3.5.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "ruby-prof"
  spec.add_development_dependency "minitest"
end
