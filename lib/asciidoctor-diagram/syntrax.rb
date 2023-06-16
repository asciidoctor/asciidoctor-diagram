require_relative 'extensions'
require_relative 'syntrax/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::SyntraxBlockProcessor, :syntrax
  block_macro Asciidoctor::Diagram::SyntraxBlockMacroProcessor, :syntrax
  inline_macro Asciidoctor::Diagram::SyntraxInlineMacroProcessor, :syntrax
end
