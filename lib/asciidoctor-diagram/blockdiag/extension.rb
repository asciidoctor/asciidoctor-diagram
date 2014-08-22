require_relative '../api/diagram'
require_relative '../util/cli_generator'

module Asciidoctor
  module Diagram
    # @private
    module BlockDiag
      def self.define_processors(name, &init)
        block = Class.new(API::DiagramBlockProcessor) do
          self.instance_eval &init
        end
        ::Asciidoctor::Diagram.const_set("#{name}BlockProcessor", block)

        block_macro = Class.new(API::DiagramBlockMacroProcessor) do
          self.instance_eval &init
        end

        ::Asciidoctor::Diagram.const_set("#{name}BlockMacroProcessor", block_macro)
      end
    end

    # @!parse
    #   class BlockDiagBlockProcessor < DiagramBlockProcessor; end
    #   class BlockDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    #   class SeqDiagBlockProcessor < DiagramBlockProcessor; end
    #   class SeqDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    #   class ActDiagBlockProcessor < DiagramBlockProcessor; end
    #   class ActDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    #   class NwDiagBlockProcessor < DiagramBlockProcessor; end
    #   class NwDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    #   class RackDiagBlockProcessor < DiagramBlockProcessor; end
    #   class RackDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    #   class PacketDiagBlockProcessor < DiagramBlockProcessor; end
    #   class PacketDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end
    ['BlockDiag', 'SeqDiag', 'ActDiag', 'NwDiag', 'RackDiag', 'PacketDiag'].each do |tool|
      BlockDiag.define_processors(tool) do
        [:png, :svg].each do |f|
          register_format(f, :image) do |c, p|
            CliGenerator.generate(tool.downcase, p, c.to_s) do |tool_path, output_path|
              [tool_path, '-o', output_path, "-T#{f.to_s}", '-']
            end
          end
        end
      end
    end
  end
end