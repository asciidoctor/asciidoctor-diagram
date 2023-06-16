require_relative 'extensions'
require_relative 'pikchr/extension'

Asciidoctor::Diagram::Extensions.register do
  block Asciidoctor::Diagram::PikchrBlockProcessor, :pikchr
  block_macro Asciidoctor::Diagram::PikchrBlockMacroProcessor, :pikchr
  inline_macro Asciidoctor::Diagram::PikchrInlineMacroProcessor, :pikchr
end
