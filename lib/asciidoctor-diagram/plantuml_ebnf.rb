require 'asciidoctor/extensions'
require_relative 'plantuml/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PlantUmlEbnfBlockProcessor, :plantuml_ebnf
  block_macro Asciidoctor::Diagram::PlantUmlEbnfBlockMacroProcessor, :plantuml_ebnf
  inline_macro Asciidoctor::Diagram::PlantUmlEbnfInlineMacroProcessor, :plantuml_ebnf
end
