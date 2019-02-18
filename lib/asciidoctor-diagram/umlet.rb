require 'asciidoctor/extensions'
require_relative 'umlet/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::UmletBlockProcessor, :umlet
  block_macro Asciidoctor::Diagram::UmletBlockMacroProcessor, :umlet
end
