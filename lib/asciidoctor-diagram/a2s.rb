require 'asciidoctor/extensions'
require_relative 'a2s/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::AsciiToSvgBlockProcessor, :a2s
  block_macro Asciidoctor::Diagram::AsciiToSvgBlockMacroProcessor, :a2s
end
