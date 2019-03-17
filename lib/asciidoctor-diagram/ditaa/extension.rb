require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class DitaaBlockProcessor < DiagramBlockProcessor
      use_converter DitaaConverter
    end

    class DitaaBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter DitaaConverter
    end
  end
end