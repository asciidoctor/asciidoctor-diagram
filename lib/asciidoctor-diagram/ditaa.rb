require_relative 'extensions'
require_relative 'ditaa/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::DitaaBlockProcessor, :ditaa
  block_macro Asciidoctor::Diagram::DitaaBlockMacroProcessor, :ditaa
  inline_macro Asciidoctor::Diagram::DitaaInlineMacroProcessor, :ditaa
end
