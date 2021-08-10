require 'asciidoctor/extensions'
require_relative 'meme/extension'

Asciidoctor::Extensions.register do
  block_macro Asciidoctor::Diagram::MemeBlockMacroProcessor, :meme
  inline_macro Asciidoctor::Diagram::MemeInlineMacroProcessor, :meme
end
