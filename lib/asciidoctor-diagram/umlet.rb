require 'asciidoctor/extensions'
require_relative 'umlet/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::UmletBlockProcessor, :umlet
  block_macro Asciidoctor::Diagram::UmletBlockMacroProcessor, :umlet
  inline_macro Asciidoctor::Diagram::UmletInlineMacroProcessor, :umlet
end
