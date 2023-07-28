require 'asciidoctor/extensions'
require_relative 'penrose/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PenroseBlockProcessor, :penrose
  block_macro Asciidoctor::Diagram::PenroseBlockMacroProcessor, :penrose
  inline_macro Asciidoctor::Diagram::PenroseInlineMacroProcessor, :penrose
end
