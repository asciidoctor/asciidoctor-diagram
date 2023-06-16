require_relative 'extensions'
require_relative 'msc/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::MscBlockProcessor, :msc
  block_macro Asciidoctor::Diagram::MscBlockMacroProcessor, :msc
  inline_macro Asciidoctor::Diagram::MscInlineMacroProcessor, :msc
end
