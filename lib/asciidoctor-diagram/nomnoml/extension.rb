require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class NomnomlBlockProcessor < DiagramBlockProcessor
      use_converter NomnomlConverter
    end

    class NomnomlBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter NomnomlConverter
    end

    class NomnomlInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter NomnomlConverter
    end
  end
end
