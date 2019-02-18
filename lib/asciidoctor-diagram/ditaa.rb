require 'asciidoctor/extensions'
require_relative 'ditaa/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::DitaaBlockProcessor, :ditaa
  block_macro Asciidoctor::Diagram::DitaaBlockMacroProcessor, :ditaa
end
