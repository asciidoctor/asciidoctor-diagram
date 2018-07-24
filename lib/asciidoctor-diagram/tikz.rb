require_relative 'extensions'

Asciidoctor::Extensions.register do
  require_relative 'tikz/extension'
  block Asciidoctor::Diagram::TikZBlockProcessor, :tikz
  block_macro Asciidoctor::Diagram::TikZBlockMacroProcessor, :tikz
end
