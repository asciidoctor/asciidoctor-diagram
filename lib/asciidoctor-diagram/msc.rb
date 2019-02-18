require 'asciidoctor/extensions'
require_relative 'msc/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::MscBlockProcessor, :msc
  block_macro Asciidoctor::Diagram::MscBlockMacroProcessor, :msc
end
