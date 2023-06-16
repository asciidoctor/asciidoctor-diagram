require_relative 'extensions'
require_relative 'erd/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::ErdBlockProcessor, :erd
  block_macro Asciidoctor::Diagram::ErdBlockMacroProcessor, :erd
  inline_macro Asciidoctor::Diagram::ErdInlineMacroProcessor, :erd
end
