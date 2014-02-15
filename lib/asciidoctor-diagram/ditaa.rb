require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'ditaa/extension'
  block :ditaa, Asciidoctor::Diagram::DitaaBlock
  block_macro :ditaa, Asciidoctor::Diagram::DitaaBlockMacro
end
