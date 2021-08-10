require 'asciidoctor/extensions'
require_relative 'shaape/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::ShaapeBlockProcessor, :shaape
  block_macro Asciidoctor::Diagram::ShaapeBlockMacroProcessor, :shaape
  inline_macro Asciidoctor::Diagram::ShaapeInlineMacroProcessor, :shaape
end
