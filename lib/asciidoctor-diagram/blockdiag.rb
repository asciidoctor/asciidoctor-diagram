require 'asciidoctor/extensions'
require_relative 'version'

Asciidoctor::Extensions.register do
  require_relative 'blockdiag/extension'

  ['BlockDiag', 'SeqDiag', 'ActDiag', 'NwDiag', 'RackDiag', 'PacketDiag'].each do |tool|
    name = tool.downcase.to_sym
    block = Asciidoctor::Diagram.const_get("#{tool}Block")
    block_macro = Asciidoctor::Diagram.const_get("#{tool}BlockMacro")

    block block, name
    block_macro block_macro, name
  end
end
