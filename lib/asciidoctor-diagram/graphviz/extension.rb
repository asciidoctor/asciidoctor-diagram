require_relative '../util/diagram'
require_relative '../plantuml/generator'

module Asciidoctor
  module Diagram
    module GraphvizBase
      include PlantUmlGenerator

      private

      def register_formats
        register_format(:png, :image) do |c, p|
          plantuml(p, c, 'dot')
        end
        register_format(:svg, :image) do |c, p|
          plantuml(p, c, 'dot', '-tsvg')
        end
      end
    end

    class GraphvizBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessorBase
      include GraphvizBase

      def initialize(context, document, opts = {})
        super
        register_formats()
      end
    end

    class GraphvizBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessorBase
      include GraphvizBase

      def initialize(context, document, opts = {})
        super
        register_formats()
      end
    end
  end
end
