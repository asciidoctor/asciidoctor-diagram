require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    module BarcodeProcessor
      def self.check_config(config = {})
        type = config[:type]
        raise "Barcode type not specified in config" if type.nil?
        raise "Unsupported barcode type: '#{type}'" unless BarcodeConverter::BARCODE_TYPES.include?(type)
      end

      def initialize(name = nil, config = {})
        super
        BarcodeProcessor.check_config(config)
      end
    end

    module BarcodeMacroProcessor
      def create_source(parent, target, attributes)
        if attributes['external']
          super
        else
          code = parent.sub_attributes(target, :attribute_missing => 'warn')
          ::Asciidoctor::Diagram::ReaderSource.new(self, parent, code, attributes)
        end
      end
    end

    class BarcodeBlockProcessor < DiagramBlockProcessor
      use_converter BarcodeConverter
      include BarcodeProcessor
    end

    class BarcodeBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter BarcodeConverter
      include BarcodeProcessor
      include BarcodeMacroProcessor
    end

    class BarcodeInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter BarcodeConverter
      include BarcodeProcessor
      include BarcodeMacroProcessor
    end
  end
end
