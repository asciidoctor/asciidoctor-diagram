require_relative 'extensions'
require_relative 'svgbob/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::SvgBobBlockProcessor, :svgbob
  block_macro Asciidoctor::Diagram::SvgBobBlockMacroProcessor, :svgbob
  inline_macro Asciidoctor::Diagram::SvgBobInlineMacroProcessor, :svgbob
end
