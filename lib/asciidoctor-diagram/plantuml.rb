require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'plantuml/extension'

  block Asciidoctor::Diagram::PlantUmlBlock, :plantuml
  block_macro Asciidoctor::Diagram::PlantUmlBlockMacro, :plantuml
end
