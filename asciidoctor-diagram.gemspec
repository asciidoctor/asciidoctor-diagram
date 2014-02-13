# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciidoctor-diagram/version'

$platform ||= RUBY_PLATFORM[/java/] || 'ruby'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-diagram"
  spec.version       = Asciidoctor::Diagram::VERSION
  spec.authors       = ["Pepijn Van Eeckhoudt"]
  spec.email         = ["pepijn@vaneeckhoudt.net"]
  spec.description   = %q{Asciidoctor diagramming extension}
  spec.summary       = %q{An extension for asciidoctor that adds support for UML diagram generation using PlantUML}
  spec.platform      = $platform
  spec.homepage      = "https://github.com/asciidoctor/asciidoctor-diagram"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "asciidoctor", "~> 0.1.4"
  spec.add_runtime_dependency "rjb", "~> 1.4.9" unless $platform == 'java'
end
