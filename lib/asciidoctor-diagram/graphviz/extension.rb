require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class GraphvizBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter GraphvizConverter
    end

    class GraphvizBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter GraphvizConverter
    end
  end
end
