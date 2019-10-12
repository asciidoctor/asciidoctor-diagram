require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class GraphvizBlockProcessor < DiagramBlockProcessor
      use_converter GraphvizConverter
    end

    class GraphvizBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter GraphvizConverter
    end
  end
end
