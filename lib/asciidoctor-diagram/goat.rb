require "asciidoctor/extensions"
require_relative "goat/extension"

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::GoATBlockProcessor, :goat
  block_macro Asciidoctor::Diagram::GoATBlockMacroProcessor, :goat
  inline_macro Asciidoctor::Diagram::GoATInlineMacroProcessor, :goat
end
