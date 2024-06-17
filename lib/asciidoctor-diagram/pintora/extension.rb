require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class PintoraBlockProcessor < DiagramBlockProcessor
      use_converter PintoraConverter
    end

    class PintoraBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter PintoraConverter
    end

    class PintoraInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter PintoraConverter
    end
  end
end
