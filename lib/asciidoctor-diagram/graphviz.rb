require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'graphviz/extension'
  block Asciidoctor::Diagram::GraphvizBlock, :graphviz
  block_macro Asciidoctor::Diagram::GraphvizBlockMacro, :graphviz
end
