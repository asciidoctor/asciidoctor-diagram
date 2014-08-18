require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'cacoo/extension'
  block Asciidoctor::Diagram::CacooBlock, :cacoo
  block_macro Asciidoctor::Diagram::CacooBlockMacro, :cacoo
end
