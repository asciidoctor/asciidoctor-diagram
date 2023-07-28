require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class PenroseBlockProcessor < DiagramBlockProcessor
      use_converter PenroseConverter
    end

    class PenroseBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter PenroseConverter
    end

    class PenroseInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter PenroseConverter
    end
  end
end
