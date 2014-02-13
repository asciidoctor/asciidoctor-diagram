require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    class PlantUmlBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramBlockProcessor
      include PlantUmlGenerator

      def initialize(context, document, opts = {})
        super

        args = ['uml']

        config = document.attributes['plantumlconfig']
        if config
          args += ['-config', File.expand_path(config, document.attributes['docdir'])]
        end

        register_format(:png, :image, :plantuml, args)
        register_format(:svg, :image, :plantuml, args + ['-tsvg'])
        register_format(:txt, :literal, :plantuml, args + ['-tutxt'])
      end
    end
  end
end
