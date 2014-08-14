require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'blockdiag/extension'
  block Asciidoctor::Diagram::BlockDiagBlock, :blockdiag
  block_macro Asciidoctor::Diagram::BlockDiagBlockMacro, :blockdiag
end
