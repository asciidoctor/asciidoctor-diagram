require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'ditaa/extension'
  block Asciidoctor::Diagram::DitaaBlockProcessor, :ditaa
  block_macro Asciidoctor::Diagram::DitaaBlockMacroProcessor, :ditaa
end
