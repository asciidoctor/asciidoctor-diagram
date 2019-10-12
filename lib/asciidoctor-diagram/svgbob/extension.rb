require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class SvgBobBlockProcessor < DiagramBlockProcessor
      use_converter SvgbobConverter
    end

    class SvgBobBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SvgbobConverter
    end
  end
end
