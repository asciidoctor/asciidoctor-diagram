require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    module DitaaBase
      include DitaaGenerator

      private

      def register_formats
        register_format(:png, :image) do |c|
          ditaa(c)
        end
      end
    end

    class DitaaBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessorBase
      include DitaaBase

      def initialize(context, document, opts = {})
        super
        register_formats()
      end
    end

    class DitaaBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessorBase
      include DitaaBase

      def initialize(context, document, opts = {})
        super
        register_formats()
      end
    end
  end
end