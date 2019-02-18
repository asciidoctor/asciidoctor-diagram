require 'asciidoctor/extensions'
require_relative 'vega/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::VegaBlockProcessor, :vega
  block_macro Asciidoctor::Diagram::VegaBlockMacroProcessor, :vega

  block Asciidoctor::Diagram::VegaBlockProcessor, :vegalite
  block_macro Asciidoctor::Diagram::VegaBlockMacroProcessor, :vegalite
end
