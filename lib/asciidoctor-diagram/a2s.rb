require_relative 'extensions'
require_relative 'a2s/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::AsciiToSvgBlockProcessor, :a2s
  block_macro Asciidoctor::Diagram::AsciiToSvgBlockMacroProcessor, :a2s
  inline_macro Asciidoctor::Diagram::AsciiToSvgInlineMacroProcessor, :a2s
end
