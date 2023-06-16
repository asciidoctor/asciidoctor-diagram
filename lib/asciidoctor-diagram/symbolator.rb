require_relative 'extensions'
require_relative 'symbolator/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::SymbolatorBlockProcessor, :symbolator
  block_macro Asciidoctor::Diagram::SymbolatorBlockMacroProcessor, :symbolator
  inline_macro Asciidoctor::Diagram::SymbolatorInlineMacroProcessor, :symbolator
end
