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

  begin
    s.files             = `git ls-files -z --exclude=deps/* -- */* :!:deps {CHANGELOG,LICENSE,README,Rakefile}*`.split "\0"
  rescue
    s.files             = Dir['**/*']
  end

  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.add_runtime_dependency 'asciidoctor', '>= 1.5.7', '< 3.x'
  s.add_runtime_dependency 'asciidoctor-diagram-ditaamini', '~> 0.14'
  s.add_runtime_dependency 'asciidoctor-diagram-plantuml', '~> 1.2021'
  s.add_runtime_dependency 'rexml'
end
