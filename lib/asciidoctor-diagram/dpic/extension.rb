require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class DpicBlockProcessor < DiagramBlockProcessor
      use_converter DpicConverter
    end

    class DpicBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter DpicConverter
    end
  end
end
