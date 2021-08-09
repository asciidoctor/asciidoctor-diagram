source 'https://rubygems.org'

gemspec :name => 'asciidoctor-diagram'
gemspec :name => 'asciidoctor-diagram-ditaamini', :path => 'deps/ditaa'
gemspec :name => 'asciidoctor-diagram-plantuml', :path => 'deps/plantuml'

require_relative 'lib/asciidoctor-diagram/barcode/dependencies'
Asciidoctor::Diagram::BarcodeDependencies::ALL_DEPENDENCIES.each_pair do |name, version|
  gem name, version
end