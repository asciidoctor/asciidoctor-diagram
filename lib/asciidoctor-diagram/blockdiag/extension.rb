require_relative '../util/cli_generator'
require_relative '../util/diagram'

module Asciidoctor
  module Diagram
    def self.define_processors(name, &init)
      block = Class.new(DiagramBlockProcessor) do
        self.instance_eval &init
      end
      ::Asciidoctor::Diagram.const_set("#{name}BlockProcessor", block)

      block_macro = Class.new(DiagramBlockMacroProcessor) do
        self.instance_eval &init
      end

      ::Asciidoctor::Diagram.const_set("#{name}BlockMacroProcessor", block_macro)
    end

    ['BlockDiag', 'SeqDiag', 'ActDiag', 'NwDiag', 'RackDiag', 'PacketDiag'].each do |tool|
      define_processors(tool) do
        [:png, :svg].each do |f|
          register_format(f, :image) do |c, p|
            CliGenerator.generate(tool.downcase, p, c) do |tool_path, output_path|
              [tool_path, '-o', output_path, "-T#{f.to_s}", '-']
            end
          end
        end
      end
    end
  end
end