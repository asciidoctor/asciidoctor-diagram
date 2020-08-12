require 'asciidoctor/extensions'
require_relative 'symbolator/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::SymbolatorBlockProcessor, :symbolator
  block_macro Asciidoctor::Diagram::SymbolatorBlockMacroProcessor, :symbolator
end
