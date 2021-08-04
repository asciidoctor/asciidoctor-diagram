require 'asciidoctor/extensions'
require_relative 'barcode/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::BarcodeBlockProcessor, :barcode
  block_macro Asciidoctor::Diagram::BarcodeBlockMacroProcessor, :barcode
  inline_macro Asciidoctor::Diagram::BarcodeInlineMacroProcessor, :barcode
end
