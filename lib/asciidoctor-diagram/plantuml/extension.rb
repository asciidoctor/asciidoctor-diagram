require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    define_processors('PlantUml') do
      def config_args(parent)
        config_args = []
        config = parent.document.attributes['plantumlconfig']
        if config
          config_args += ['-config', File.expand_path(config, parent.document.attributes['docdir'])]
        end

        config_args
      end

      register_format(:png, :image) do |c, p|
        PlantUmlGenerator.plantuml(p, c, 'uml', *config_args(p))
      end
      register_format(:svg, :image) do |c, p|
        PlantUmlGenerator.plantuml(p, c, 'uml', '-tsvg', *config_args(p))
      end
      register_format(:txt, :literal) do |c, p|
        PlantUmlGenerator.plantuml(p, c, 'uml', '-tutxt', *config_args(p))
      end
    end
  end
end
