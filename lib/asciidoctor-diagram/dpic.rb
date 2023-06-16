require_relative 'extensions'
require_relative 'dpic/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::DpicBlockProcessor, :dpic
  block_macro Asciidoctor::Diagram::DpicBlockMacroProcessor, :dpic
  inline_macro Asciidoctor::Diagram::DpicInlineMacroProcessor, :dpic
end
