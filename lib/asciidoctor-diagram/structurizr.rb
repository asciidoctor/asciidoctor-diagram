require 'asciidoctor/extensions'
require_relative 'structurizr/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::StructurizrBlockProcessor, :structurizr
  block_macro Asciidoctor::Diagram::StructurizrBlockMacroProcessor, :structurizr
end
