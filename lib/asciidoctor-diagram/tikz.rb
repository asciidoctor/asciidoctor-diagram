require 'asciidoctor/extensions'
require_relative 'tikz/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::TikZBlockProcessor, :tikz
  block_macro Asciidoctor::Diagram::TikZBlockMacroProcessor, :tikz
end
