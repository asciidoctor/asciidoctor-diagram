require_relative 'extensions'
require_relative 'lilypond/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::LilypondBlockProcessor, :lilypond
  block_macro Asciidoctor::Diagram::LilypondBlockMacroProcessor, :lilypond
  inline_macro Asciidoctor::Diagram::LilypondInlineMacroProcessor, :lilypond
end
