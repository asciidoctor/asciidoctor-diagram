require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'plantuml/extension'
  block :plantuml, Asciidoctor::Diagram::PlantUmlBlock
  block_macro :plantuml, Asciidoctor::Diagram::PlantUmlBlockMacro
end
