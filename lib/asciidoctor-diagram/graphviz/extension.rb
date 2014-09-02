require_relative '../extensions'
require_relative '../util/cli_generator'

module Asciidoctor
  module Diagram
    # @private
    module Graphviz
      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            CliGenerator.generate('dot', p, c.to_s) do |tool_path, output_path|
              [tool_path, "-o#{output_path}", "-T#{f.to_s}"]
            end
          end
        end
      end
    end

    class GraphvizBlockProcessor < Extensions::DiagramBlockProcessor
      include Graphviz
    end

    class GraphvizBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Graphviz
    end
  end
end
