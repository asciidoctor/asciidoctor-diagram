module Asciidoctor
  module Diagram
    class Renderers
      D2 = 'd2'
      GRAPHVIZ = 'graphviz'
      MERMAID = 'mermaid'
      PLANTUML_C4 = 'plantuml-c4'
      PLANTUML = 'plantuml'
      DEFAULT_RENDERER = PLANTUML_C4

      def initialize(name)
        @d2 = D2BlockProcessor.new(name)
        @graphviz = GraphvizBlockProcessor.new(name)
        @plantuml = PlantUmlBlockProcessor.new(name)
        @mermaid = MermaidBlockProcessor.new(name)
      end

      def renderer(renderer_type)
        case renderer_type
        when D2
          @d2
        when GRAPHVIZ
          @graphviz
        when MERMAID
          @mermaid
        when PLANTUML, PLANTUML_C4
          @plantuml
        else
          raise "Unsupported renderer: '#{renderer_type}'"
        end
      end

      def get_renderer(source)
        renderer(Renderers.get_renderer_type(source))
      end

      def self.get_renderer_type(source)
        source.attr('renderer', 'plantuml-c4')
      end
      def self.mime_type(renderer_type)
        case renderer_type
        when D2
          'text/x-d2'
        when GRAPHVIZ
          'text/vnd.graphviz'
        when MERMAID
          'text/x-mermaid'
        when PLANTUML
          'text/x-plantuml'
        when PLANTUML_C4
          'text/x-plantuml-c4'
        else
          raise "Unsupported renderer: '#{renderer_type}'"
        end
      end
    end
  end
end