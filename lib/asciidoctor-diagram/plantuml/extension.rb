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

    class SaltBlockProcessor < DiagramBlockProcessor
      use_converter SaltConverter
    end

    class SaltBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SaltConverter
    end
  end
end
