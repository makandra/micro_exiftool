# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'micro_exiftool/version'

Gem::Specification.new do |spec|
  spec.name          = "micro_exiftool"
  spec.version       = MicroExiftool::VERSION
  spec.authors       = ["Tobias Kraze"]
  spec.email         = ["tobias.kraze@makandra.de"]
  spec.summary       = %q{Minimal ruby wrapper around exiftool..}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.metadata['allowed_push_host'] = 'dont push for now'
end
