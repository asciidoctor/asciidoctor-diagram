require 'asciidoctor/extensions'
require_relative 'nomnoml/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::NomnomlBlockProcessor, :nomnoml
  block_macro Asciidoctor::Diagram::NomnomlBlockMacroProcessor, :nomnoml
end
