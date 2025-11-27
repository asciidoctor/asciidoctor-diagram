require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class VhsBlockProcessor < DiagramBlockProcessor
      use_converter VhsConverter
    end

    class VhsBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter VhsConverter
    end

    class VhsInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter VhsConverter
    end
  end
end

