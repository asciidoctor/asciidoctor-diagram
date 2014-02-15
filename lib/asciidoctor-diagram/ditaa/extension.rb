require_relative '../util/diagram'
require_relative 'generator'

module Asciidoctor
  module Diagram
    class DitaaBlock < Asciidoctor::Extensions::BlockProcessor
      include DiagramBlockProcessor
      include DitaaGenerator

      def initialize(context, document, opts = {})
        super

        register_format(:png, :image) do |c|
          ditaa(c)
        end
      end
    end
  end
end