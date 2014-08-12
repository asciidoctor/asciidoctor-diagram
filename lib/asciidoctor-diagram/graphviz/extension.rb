require_relative '../util/diagram'
require_relative '../plantuml/generator'

module Asciidoctor
  module Diagram
    module Diagram
      DiagramProcessor.define_processors('Graphviz') do
        register_format(:png, :image) do |c, p|
          PlantUmlGenerator.plantuml(p, c, 'dot')
        end
        register_format(:svg, :image) do |c, p|
          PlantUmlGenerator.plantuml(p, c, 'dot', '-tsvg')
        end
      end
    end
  end
end
