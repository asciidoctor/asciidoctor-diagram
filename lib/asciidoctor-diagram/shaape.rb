require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'shaape/extension'
  block :shaape, Asciidoctor::Diagram::ShaapeBlock
  block_macro :shaape, Asciidoctor::Diagram::ShaapeBlockMacro
end
