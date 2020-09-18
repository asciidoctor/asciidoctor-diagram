require 'asciidoctor/extensions'
require_relative 'pikchr/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::PikchrBlockProcessor, :pikchr
  block_macro Asciidoctor::Diagram::PikchrBlockMacroProcessor, :pikchr
end
