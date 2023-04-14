require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class DbmlBlockProcessor < DiagramBlockProcessor
      use_converter DbmlConverter
    end

    class DbmlBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter DbmlConverter
    end

    class DbmlInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter DbmlConverter
    end
  end
end
