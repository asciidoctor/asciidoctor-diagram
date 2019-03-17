require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class ErdBlockProcessor < DiagramBlockProcessor
      use_converter ErdConverter
    end

    class ErdBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter ErdConverter
    end
  end
end
