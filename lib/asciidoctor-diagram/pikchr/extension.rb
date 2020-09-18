require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class PikchrBlockProcessor < DiagramBlockProcessor
      use_converter PikchrConverter
    end

    class PikchrBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter PikchrConverter
    end
  end
end
