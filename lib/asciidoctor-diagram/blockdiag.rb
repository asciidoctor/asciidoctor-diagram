require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'blockdiag/extension'
  block :blockdiag, Asciidoctor::Diagram::BlockDiagBlock
  block_macro :blockdiag, Asciidoctor::Diagram::BlockDiagBlockMacro
end
