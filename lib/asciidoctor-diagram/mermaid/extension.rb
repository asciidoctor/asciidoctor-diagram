require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class MermaidBlockProcessor < DiagramBlockProcessor
      use_converter MermaidConverter
    end

    class MermaidBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter MermaidConverter
    end
  end
end
