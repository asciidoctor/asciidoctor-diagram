require 'asciidoctor/extensions'
require_relative 'vhs/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::VhsBlockProcessor, :tape
  block_macro Asciidoctor::Diagram::VhsBlockMacroProcessor, :tape
  inline_macro Asciidoctor::Diagram::VhsInlineMacroProcessor, :tape
end

