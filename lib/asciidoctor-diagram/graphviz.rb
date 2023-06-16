require_relative 'extensions'
require_relative 'graphviz/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::GraphvizBlockProcessor, :graphviz
  block_macro Asciidoctor::Diagram::GraphvizBlockMacroProcessor, :graphviz
  inline_macro Asciidoctor::Diagram::GraphvizInlineMacroProcessor, :graphviz
end
