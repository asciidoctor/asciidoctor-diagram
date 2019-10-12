require 'asciidoctor/extensions'
require_relative 'lilypond/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::LilypondBlockProcessor, :lilypond
  block_macro Asciidoctor::Diagram::LilypondBlockMacroProcessor, :lilypond
end
