require 'asciidoctor/extensions'
require_relative 'erd/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::ErdBlockProcessor, :erd
  block_macro Asciidoctor::Diagram::ErdBlockMacroProcessor, :erd
end
