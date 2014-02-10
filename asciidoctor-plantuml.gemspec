# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciidoctor-plantuml/version'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-plantuml"
  spec.version       = Asciidoctor::PlantUml::VERSION
  spec.authors       = ["Pepijn Van Eeckhoudt"]
  spec.email         = ["pepijn@vaneeckhoudt.net"]
  spec.description   = %q{Asciidoctor PlantUML extension}
  spec.summary       = %q{An extension for asciidoctor that adds support for UML diagram generation using PlantUML}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "asciidoctor", "~> 0.1.4"
  spec.add_runtime_dependency "rjb", "~> 1.4.9" unless RUBY_PLATFORM == 'java'
end
