require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class BarcodeBlockProcessor < DiagramBlockProcessor
      name_positional_attributes ['type', 'target', 'format']
      use_converter BarcodeConverter
    end

    module BarcodeMacroProcessor
      class StringReader
        def initialize(str)
          @str = str
        end

        def lines
          @str.lines.map { |l| l.rstrip }
        end
      end

      def create_source(parent, target, attributes)
        attributes = attributes.dup
        attributes['type'] = parent.sub_attributes(target, :attribute_missing => 'warn')
        code = attributes['code'] || ''
        ::Asciidoctor::Diagram::ReaderSource.new(self, parent, StringReader.new(code), attributes)
      end
    end

    class BarcodeBlockMacroProcessor < DiagramBlockMacroProcessor
      name_positional_attributes ['code', 'format']
      use_converter BarcodeConverter
      include BarcodeMacroProcessor
    end

    class BarcodeInlineMacroProcessor < DiagramInlineMacroProcessor
      name_positional_attributes ['code', 'format']
      use_converter BarcodeConverter
      include BarcodeMacroProcessor
    end
  end
end
