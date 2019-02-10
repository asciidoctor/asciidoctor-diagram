require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class AsciiToSvgBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter AsciiToSvgConverter
    end

    class AsciiToSvgBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter AsciiToSvgConverter
    end
  end
end
