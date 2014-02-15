require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    module PlantUmlBase
      include PlantUmlGenerator

      private

      def register_formats(document)
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

    class PlantUmlBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessorBase
      include PlantUmlBase

      def initialize(context, document, opts = {})
        super
        register_formats(document)
      end
    end

    class PlantUmlBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessorBase
      include PlantUmlBase

      def initialize(context, document, opts = {})
        super
        register_formats(document)
      end
    end
  end
end
