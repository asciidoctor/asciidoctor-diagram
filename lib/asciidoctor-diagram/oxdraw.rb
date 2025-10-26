require 'asciidoctor/extensions'
require_relative 'oxdraw/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::OxdrawBlockProcessor, :oxdraw
  block_macro Asciidoctor::Diagram::OxdrawBlockMacroProcessor, :oxdraw
  inline_macro Asciidoctor::Diagram::OxdrawInlineMacroProcessor, :oxdraw
end
