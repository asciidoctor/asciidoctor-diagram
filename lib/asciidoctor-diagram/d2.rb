require 'asciidoctor/extensions'
require_relative 'd2/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::D2BlockProcessor, :d2
  block_macro Asciidoctor::Diagram::D2BlockMacroProcessor, :d2
  inline_macro Asciidoctor::Diagram::D2InlineMacroProcessor, :d2
end
