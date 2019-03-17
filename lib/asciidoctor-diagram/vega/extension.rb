require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class VegaBlockProcessor < DiagramBlockProcessor
      use_converter VegaConverter
    end

    class VegaBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter VegaConverter
    end
  end
end
