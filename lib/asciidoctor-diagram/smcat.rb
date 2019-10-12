require 'asciidoctor/extensions'
require_relative 'smcat/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::SmcatBlockProcessor, :smcat
  block_macro Asciidoctor::Diagram::SmcatBlockMacroProcessor, :smcat
end
