require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    module PlantUmlBase
      include PlantUmlGenerator

      private

      def register_formats()
        register_format(:png, :image) do |c, p|
          plantuml(p, c, 'uml')
        end
        register_format(:svg, :image) do |c, p|
          plantuml(p, c, 'uml', '-tsvg')
        end
        register_format(:txt, :literal) do |c, p|
          plantuml(p, c, 'uml', '-tutxt')
        end
      end
    end

    class PlantUmlBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessorBase
      include PlantUmlBase

      def initialize name = nil, config = {}
        super
        register_formats()
      end
    end

    class PlantUmlBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessorBase
      include PlantUmlBase

      def initialize name = nil, config = {}
        super
        register_formats()
      end
    end
  end
end
