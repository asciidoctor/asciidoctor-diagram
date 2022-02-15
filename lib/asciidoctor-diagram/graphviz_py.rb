require 'asciidoctor/extensions'
require_relative 'graphviz_py/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::GraphvizPyBlockProcessor, :graphviz_py
  block_macro Asciidoctor::Diagram::GraphvizPyBlockMacroProcessor, :graphviz_py
  inline_macro Asciidoctor::Diagram::GraphvizPyInlineMacroProcessor, :graphviz_py
end
