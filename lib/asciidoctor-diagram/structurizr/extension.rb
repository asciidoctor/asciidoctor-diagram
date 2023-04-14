require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class StructurizrConvertBlockProcessor < DiagramBlockProcessor
      use_converter StructurizrConverter
    end

    class StructurizrBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      DiagramBlockProcessor.inherited(self)

      def initialize(name = nil, config = nil)
        super
        @structurizr = StructurizrConvertBlockMacroProcessor.new(name)
        @plantuml = PlantUmlBlockProcessor.new(name)
      end

      def process parent, reader, attributes
        structurizr_attrs = attributes.dup
        structurizr_attrs['format'] = 'txt'

        plantuml_block = @structurizr.process(parent, reader, structurizr_attrs)
        @plantuml.process(parent, plantuml_block, attributes)
      end
    end

    class StructurizrConvertBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter StructurizrConverter
    end

    class StructurizrBlockMacroProcessor < Asciidoctor::Extensions::BlockMacroProcessor
      DiagramBlockMacroProcessor.inherited(self)

      def initialize(name = nil, config = nil)
        super
        @structurizr = StructurizrConvertBlockMacroProcessor.new(name)
        @plantuml = PlantUmlBlockProcessor.new(name)
      end

      def process parent, target, attributes
        structurizr_attrs = attributes.dup
        structurizr_attrs['format'] = 'txt'

        plantuml_block = @structurizr.process(parent, target, structurizr_attrs)
        @plantuml.process(parent, plantuml_block, attributes)
      end
    end
  end
end