require 'asciidoctor/extensions'
require_relative 'dpic/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::DpicBlockProcessor, :dpic
  block_macro Asciidoctor::Diagram::DpicBlockMacroProcessor, :dpic
  inline_macro Asciidoctor::Diagram::DpicInlineMacroProcessor, :dpic
end
