require_relative 'extensions'
require_relative 'diagrams/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::DiagramsBlockProcessor, :diagrams
  block_macro Asciidoctor::Diagram::DiagramsBlockMacroProcessor, :diagrams
  inline_macro Asciidoctor::Diagram::DiagramsInlineMacroProcessor, :diagrams
end
