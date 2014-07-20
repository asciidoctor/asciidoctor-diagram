require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    module ShaapeBase
      include ShaapeGenerator

      private

      def register_formats
        register_format(:png, :image) do |c, p|
          shaape(p, c, :png)
        end

        register_format(:svg, :image) do |c, p|
          shaape(p, c, :svg)
        end
      end
    end

    class ShaapeBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessorBase
      include ShaapeBase

      def initialize name = nil, config = {}
        super
        register_formats
      end
    end

    class ShaapeBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessorBase
      include ShaapeBase

      def initialize name = nil, config = {}
        super
        register_formats
      end
    end
  end
end