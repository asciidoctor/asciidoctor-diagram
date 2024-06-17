require 'asciidoctor/extensions'
require_relative 'pintora/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PintoraBlockProcessor, :pintora
  block_macro Asciidoctor::Diagram::PintoraBlockMacroProcessor, :pintora
  inline_macro Asciidoctor::Diagram::PintoraInlineMacroProcessor, :pintora
end
