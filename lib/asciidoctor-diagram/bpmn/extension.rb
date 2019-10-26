require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class BpmnBlockProcessor < DiagramBlockProcessor
      use_converter BpmnConverter
    end

    class BpmnBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter BpmnConverter
    end
  end
end
