require_relative 'extensions'
require_relative 'dbml/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::DbmlBlockProcessor, :dbml
  block_macro Asciidoctor::Diagram::DbmlBlockMacroProcessor, :dbml
  inline_macro Asciidoctor::Diagram::DbmlInlineMacroProcessor, :dbml
end
