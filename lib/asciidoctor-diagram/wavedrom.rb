require 'asciidoctor/extensions'
require_relative 'wavedrom/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::WavedromBlockProcessor, :wavedrom
  block_macro Asciidoctor::Diagram::WavedromBlockMacroProcessor, :wavedrom
  inline_macro Asciidoctor::Diagram::WavedromInlineMacroProcessor, :wavedrom
end
