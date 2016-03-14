require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Graphviz
      include Which

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            graphviz(parent, source, f)
          end
        end
      end

      def graphviz(parent, source, format)
        CliGenerator.generate_stdin(which(parent, 'dot', :alt_attrs => ['graphvizdot']), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, "-o#{output_path}", "-T#{format.to_s}"]

          layout = source.attributes['layout']
          args << "-K#{layout}" if layout

          args
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
