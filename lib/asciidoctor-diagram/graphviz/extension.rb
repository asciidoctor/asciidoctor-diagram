require_relative '../util/diagram'
require_relative '../plantuml/generator'

module Asciidoctor
  module Diagram
    class GraphvizBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramBlockProcessor
      include PlantUmlGenerator

      def initialize(context, document, opts = {})
        super

        register_format(:png, :image) do |c, p|
          plantuml(p, c, 'dot')
        end
        register_format(:svg, :image) do |c, p|
          plantuml(p, c, 'dot', '-tsvg')
        end
      end
    end
  end
end
