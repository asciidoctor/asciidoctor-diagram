require_relative 'extensions'
require_relative 'structurizr/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::StructurizrBlockProcessor, :structurizr
  block_macro Asciidoctor::Diagram::StructurizrBlockMacroProcessor, :structurizr
end
