require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class MemeBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter MemeConverter

      class StringReader
        def initialize(str)
          @str = str
        end

        def lines
          @str.lines.map { |l| l.rstrip }
        end
      end

      name_positional_attributes %w(top bottom target format)

      def create_source(parent, target, attributes)
        attributes = attributes.dup
        attributes['background'] = apply_target_subs(parent, target)
        ::Asciidoctor::Diagram::ReaderSource.new(self, parent, StringReader.new(''), attributes)
      end
    end
  end
end
