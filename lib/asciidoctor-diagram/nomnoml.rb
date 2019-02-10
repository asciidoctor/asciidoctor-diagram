require_relative 'extensions'

Asciidoctor::Extensions.register do
  require_relative 'nomnoml/extension'

  block Asciidoctor::Diagram::NomnomlBlockProcessor, :nomnoml
  block_macro Asciidoctor::Diagram::NomnomlBlockMacroProcessor, :nomnoml
end
