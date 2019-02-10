require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class SvgBobBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter SvgbobConverter
    end

    class SvgBobBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter SvgbobConverter
    end
  end
end
