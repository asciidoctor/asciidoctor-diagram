require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class PlantUmlBlockProcessor < DiagramBlockProcessor
      use_converter UmlConverter
    end

    class PlantUmlBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter UmlConverter
    end

    class PlantUmlInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter UmlConverter
    end

    class PlantUmlEbnfBlockProcessor < DiagramBlockProcessor
      use_converter EbnfConverter
    end

    class PlantUmlEbnfBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter EbnfConverter
    end

    class PlantUmlEbnfInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter EbnfConverter
    end

    class SaltBlockProcessor < DiagramBlockProcessor
      use_converter SaltConverter
    end

    class SaltBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SaltConverter
    end

    class SaltInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter SaltConverter
    end
  end
end
