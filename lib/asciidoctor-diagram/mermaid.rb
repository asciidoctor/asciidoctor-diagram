require_relative 'extensions'
require_relative 'mermaid/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::MermaidBlockProcessor, :mermaid
  block_macro Asciidoctor::Diagram::MermaidBlockMacroProcessor, :mermaid
  inline_macro Asciidoctor::Diagram::MermaidInlineMacroProcessor, :mermaid
end
