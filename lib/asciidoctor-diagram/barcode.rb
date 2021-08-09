require 'asciidoctor/extensions'
require_relative 'barcode/extension'
require_relative 'barcode/converter'

Asciidoctor::Extensions.register do
  Asciidoctor::Diagram::BarcodeConverter::BARCODE_TYPES.each do |type|
    block Asciidoctor::Diagram::BarcodeBlockProcessor, type, :type => type
    block_macro Asciidoctor::Diagram::BarcodeBlockMacroProcessor, type, :type => type
    inline_macro Asciidoctor::Diagram::BarcodeInlineMacroProcessor, type, :type => type
  end
end
