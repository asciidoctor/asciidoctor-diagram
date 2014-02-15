require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    class PlantUmlBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramBlockProcessor
      include PlantUmlGenerator

      def initialize(context, document, opts = {})
        super

        config_args = []
        config = document.attributes['plantumlconfig']
        if config
          config_args += ['-config', File.expand_path(config, document.attributes['docdir'])]
        end

        register_format(:png, :image) do |c, p|
          plantuml(p, c, 'uml', *config_args)
        end
        register_format(:svg, :image) do |c, p|
          plantuml(p, c, 'uml', '-tsvg', *config_args)
        end
        register_format(:txt, :literal) do |c, p|
          plantuml(p, c, 'uml', '-tutxt', *config_args)
        end
      end
    end
  end
end
