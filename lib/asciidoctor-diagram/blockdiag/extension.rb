require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    ['BlockDiag', 'SeqDiag', 'ActDiag', 'NwDiag', 'RackDiag', 'PacketDiag'].each do |tool|
      block = Class.new(Extensions::DiagramBlockProcessor) do
        use_converter ::Asciidoctor::Diagram.const_get("#{tool}Converter")
      end
      ::Asciidoctor::Diagram.const_set("#{tool}BlockProcessor", block)

      block_macro = Class.new(Extensions::DiagramBlockMacroProcessor) do
        use_converter ::Asciidoctor::Diagram.const_get("#{tool}Converter")
      end
      ::Asciidoctor::Diagram.const_set("#{tool}BlockMacroProcessor", block_macro)
    end
  end
end
