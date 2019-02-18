require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class VegaBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter VegaConverter
    end

    class VegaBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter VegaConverter
    end
  end
end
