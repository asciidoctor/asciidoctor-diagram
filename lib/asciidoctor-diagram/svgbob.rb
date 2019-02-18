require 'asciidoctor/extensions'
require_relative 'svgbob/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::SvgBobBlockProcessor, :svgbob
  block_macro Asciidoctor::Diagram::SvgBobBlockMacroProcessor, :svgbob
end
