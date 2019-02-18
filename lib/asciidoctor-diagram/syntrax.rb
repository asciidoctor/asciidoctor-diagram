require 'asciidoctor/extensions'
require_relative 'syntrax/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::SyntraxBlockProcessor, :syntrax
  block_macro Asciidoctor::Diagram::SyntraxBlockMacroProcessor, :syntrax
end
