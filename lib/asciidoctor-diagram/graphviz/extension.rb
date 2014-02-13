require_relative '../util/diagram'
require_relative '../plantuml/generator'

module Asciidoctor
  module Diagram
    class GraphvizBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramBlockProcessor
      include PlantUmlGenerator

      def initialize(context, document, opts = {})
        super

        args = ['dot']

        register_format(:png, :image, :plantuml, args)
        register_format(:svg, :image, :plantuml, args + ['-tsvg'])
      end
    end
  end
end
