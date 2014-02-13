require_relative '../diagram'
require_relative '../java'
require_relative '../png'
require_relative '../svg'
require_relative '../plantuml/extension'

module Asciidoctor
  module Diagram
    class GraphvizBlock < PlantUmlBlock
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      private

      def name
        "Graphviz"
      end

      def allowed_formats
        @allowed_formats ||= [:svg, :png]
      end

      def get_tag
        'dot'
      end

      def get_default_flags(parent)
        []
      end
    end
  end
end
