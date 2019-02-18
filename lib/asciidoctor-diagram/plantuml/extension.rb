require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class PlantUmlBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter UmlConverter
    end

    class PlantUmlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter UmlConverter
    end

    class SaltBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter SaltConverter
    end

    class SaltBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter SaltConverter
    end
  end
end
