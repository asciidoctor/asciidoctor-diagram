require 'asciidoctor/extensions'
require_relative 'mermaid/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::MermaidBlockProcessor, :mermaid
  block_macro Asciidoctor::Diagram::MermaidBlockMacroProcessor, :mermaid
end
