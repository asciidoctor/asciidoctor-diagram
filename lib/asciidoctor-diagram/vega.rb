require_relative 'extensions'
require_relative 'vega/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::VegaBlockProcessor, :vega
  block_macro Asciidoctor::Diagram::VegaBlockMacroProcessor, :vega
  inline_macro Asciidoctor::Diagram::VegaInlineMacroProcessor, :vega

  block Asciidoctor::Diagram::VegaBlockProcessor, :vegalite
  block_macro Asciidoctor::Diagram::VegaBlockMacroProcessor, :vegalite
  inline_macro Asciidoctor::Diagram::VegaInlineMacroProcessor, :vegalite
end
