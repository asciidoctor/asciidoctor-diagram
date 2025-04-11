require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class PlantUmlNativeBlockProcessor < DiagramBlockProcessor
      use_converter PlantUmlNative
    end

    class PlantUmlNativeBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter PlantUmlNative
    end

    class PlantUmlNativeInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter PlantUmlNative
    end
  end
end
