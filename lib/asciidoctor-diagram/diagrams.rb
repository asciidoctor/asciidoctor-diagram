require 'asciidoctor/extensions'
require_relative 'diagrams/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::DiagramsBlockProcessor, :diagrams
  block_macro Asciidoctor::Diagram::DiagramsBlockMacroProcessor, :diagrams
end
