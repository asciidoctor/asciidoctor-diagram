require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class AsciiToSvgBlockProcessor < DiagramBlockProcessor
      use_converter AsciiToSvgConverter
    end

    class AsciiToSvgBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter AsciiToSvgConverter
    end
  end
end
