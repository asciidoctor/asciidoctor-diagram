require_relative '../util/cli_generator'
require_relative '../util/diagram'

module Asciidoctor
  module Diagram
    module Graphviz
      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            CliGenerator.generate('dot', p, c) do |tool_path, output_path|
              [tool_path, "-o#{output_path}", "-T#{f.to_s}"]
            end
          end
        end
      end
    end

    class GraphvizBlockProcessor < DiagramBlockProcessor
      include Graphviz
    end

    class GraphvizBlockMacroProcessor < DiagramBlockMacroProcessor
      include Graphviz
    end
  end
end
