require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class DitaaBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter DitaaConverter
    end

    class DitaaBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter DitaaConverter
    end
  end
end