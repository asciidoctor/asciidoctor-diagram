require 'asciidoctor/extensions'
require_relative 'plantuml/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::SaltBlockProcessor, :salt
  block_macro Asciidoctor::Diagram::SaltBlockMacroProcessor, :salt
  inline_macro Asciidoctor::Diagram::SaltInlineMacroProcessor, :salt
end
