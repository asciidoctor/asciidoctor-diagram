require 'asciidoctor/extensions'
require_relative 'plantuml_native/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PlantUmlNativeBlockProcessor, :plantuml_native
  block_macro Asciidoctor::Diagram::PlantUmlNativeBlockMacroProcessor, :plantuml_native
  inline_macro Asciidoctor::Diagram::PlantUmlNativeInlineMacroProcessor, :plantuml_native
end
