require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'graphviz/extension'
  block :graphviz, Asciidoctor::Diagram::GraphvizBlock
end
