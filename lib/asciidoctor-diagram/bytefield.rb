require 'asciidoctor/extensions'
require_relative 'bytefield/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::BytefieldBlockProcessor, :bytefield
  block_macro Asciidoctor::Diagram::BytefieldBlockMacroProcessor, :bytefield
  inline_macro Asciidoctor::Diagram::BytefieldInlineMacroProcessor, :bytefield
end
