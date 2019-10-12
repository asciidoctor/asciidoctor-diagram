require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class LilypondBlockProcessor < DiagramBlockProcessor
      use_converter LilypondConverter
    end

    class LilypondBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter LilypondConverter
    end
  end
end
