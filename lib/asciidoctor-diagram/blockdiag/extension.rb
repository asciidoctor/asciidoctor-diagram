require_relative '../extensions'
require_relative '../util/cli_generator'

module Asciidoctor
  module Diagram
    # @private
    module BlockDiag
      def self.define_processors(name, &init)
        block = Class.new(Extensions::DiagramBlockProcessor) do
          self.instance_eval &init
        end
        ::Asciidoctor::Diagram.const_set("#{name}BlockProcessor", block)

        block_macro = Class.new(Extensions::DiagramBlockMacroProcessor) do
          self.instance_eval &init
        end

        ::Asciidoctor::Diagram.const_set("#{name}BlockMacroProcessor", block_macro)
      end
    end

    # @!parse
    #   # Block processor converts blockdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class BlockDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts blockdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class BlockDiagBlockMacroProcessor < DiagramBlockMacroProcessor; end

    # @!parse
    #   # Block processor converts seqdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class SeqDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts seqdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class SeqDiagBlockMacroProcessor < API::DiagramBlockMacroProcessor; end

    # @!parse
    #   # Block processor converts actdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class ActDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts actdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class ActDiagBlockMacroProcessor < API::DiagramBlockMacroProcessor; end

    # @!parse
    #   # Block processor converts nwdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class NwDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts nwdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class NwDiagBlockMacroProcessor < API::DiagramBlockMacroProcessor; end

    # @!parse
    #   # Block processor converts rackdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class RackDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts rackdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class RackDiagBlockMacroProcessor < API::DiagramBlockMacroProcessor; end

    # @!parse
    #   # Block processor converts packetdiag code into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class PacketDiagBlockProcessor < API::DiagramBlockProcessor; end
    #
    #   # Block macro processor converts packetdiag source files into images.
    #   #
    #   # Supports PNG and SVG output.
    #   class PacketDiagBlockMacroProcessor < API::DiagramBlockMacroProcessor; end
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