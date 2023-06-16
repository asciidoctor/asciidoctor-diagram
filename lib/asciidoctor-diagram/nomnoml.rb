require_relative 'extensions'
require_relative 'nomnoml/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::NomnomlBlockProcessor, :nomnoml
  block_macro Asciidoctor::Diagram::NomnomlBlockMacroProcessor, :nomnoml
  inline_macro Asciidoctor::Diagram::NomnomlInlineMacroProcessor, :nomnoml
end
