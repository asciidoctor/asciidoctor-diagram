# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciidoctor-diagram/version'

Gem::Specification.new do |s|
  s.name          = 'asciidoctor-diagram'
  s.version       = Asciidoctor::Diagram::VERSION
  s.authors       = ['Pepijn Van Eeckhoudt']
  s.email         = ['pepijn@vaneeckhoudt.net']
  s.description   = %q{Asciidoctor diagramming extension}
  s.summary       = %q{A family of Asciidoctor extensions that generate images from a broad range of embedded plain text diagram descriptions, including PlantUML, ditaa, Kroki, and many others.}
  s.homepage      = 'https://github.com/asciidoctor/asciidoctor-diagram'
  s.license       = 'MIT'
  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/asciidoctor/asciidoctor-diagram/issues",
    "changelog_uri"     => "https://github.com/asciidoctor/asciidoctor-diagram/blob/main/CHANGELOG.adoc",
    "documentation_uri" => "https://docs.asciidoctor.org/diagram-extension/latest/",
    "homepage_uri"      => "https://github.com/asciidoctor/asciidoctor-diagram",
    "source_code_uri"   => "https://github.com/asciidoctor/asciidoctor-diagram.git",
  }

  s.files = Dir['lib/**/*.{rb,jar}']
  s.files << 'CHANGELOG.adoc'
  s.files << 'LICENSE.txt'
  s.files << 'README.adoc'

  s.require_paths = ['lib']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.add_runtime_dependency 'asciidoctor', '>= 1.5.7', '< 3.x'
  s.add_runtime_dependency 'asciidoctor-diagram-ditaamini', '~> 1.0'
  s.add_runtime_dependency 'asciidoctor-diagram-plantuml', '~> 1.2021'
  s.add_runtime_dependency 'rexml'
end
