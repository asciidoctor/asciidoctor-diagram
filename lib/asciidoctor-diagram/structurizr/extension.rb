require_relative 'converter'
require_relative 'renderers.rb'
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
        @structurizr = StructurizrConvertBlockProcessor.new(name)
        @renderers = Renderers.new(name)
      end

      def process parent, reader, attributes
        structurizr_attrs = attributes.dup
        structurizr_attrs['format'] = 'txt'

        renderer_block = @structurizr.process(parent, reader, structurizr_attrs)
        @renderers.get_renderer(BasicSource.new(self, parent, attributes)).process(parent, renderer_block, attributes)
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
        @renderers = Renderers.new(name)
      end

      def process parent, target, attributes
        structurizr_attrs = attributes.dup
        structurizr_attrs['format'] = 'txt'

        renderer_block = @structurizr.process(parent, target, structurizr_attrs)
        @renderers.get_renderer(BasicSource.new(self, parent, attributes)).process(parent, renderer_block, attributes)
      end
    end
  end
end