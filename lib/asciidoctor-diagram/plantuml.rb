require 'asciidoctor/extensions'
require_relative 'plantuml/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PlantUmlBlockProcessor, :plantuml
  block_macro Asciidoctor::Diagram::PlantUmlBlockMacroProcessor, :plantuml
end
