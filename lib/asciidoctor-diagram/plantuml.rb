require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'plantuml/extension'
  block :plantuml, Asciidoctor::Diagram::PlantUmlBlock
end
