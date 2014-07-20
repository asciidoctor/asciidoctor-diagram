require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'shaape/extension'

  block Asciidoctor::Diagram::ShaapeBlock, :shaape
  block_macro Asciidoctor::Diagram::ShaapeBlockMacro, :shaape
end
