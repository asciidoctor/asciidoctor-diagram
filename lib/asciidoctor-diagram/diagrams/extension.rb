require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class DiagramsBlockProcessor < DiagramBlockProcessor
      use_converter DiagramsConverter
    end

    class DiagramsBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter DiagramsConverter
    end
  end
end