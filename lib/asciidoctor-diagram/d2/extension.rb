require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class D2BlockProcessor < DiagramBlockProcessor
      use_converter D2Converter
    end

    class D2BlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter D2Converter
    end

    class D2InlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter D2Converter
    end
  end
end
