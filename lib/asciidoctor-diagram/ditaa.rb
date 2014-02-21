require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'ditaa/extension'
  block Asciidoctor::Diagram::DitaaBlock, :ditaa
  block_macro Asciidoctor::Diagram::DitaaBlockMacro, :ditaa
end
