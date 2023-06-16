require_relative 'extensions'
require_relative 'tikz/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::TikZBlockProcessor, :tikz
  block_macro Asciidoctor::Diagram::TikZBlockMacroProcessor, :tikz
  inline_macro Asciidoctor::Diagram::TikZInlineMacroProcessor, :tikz
end
