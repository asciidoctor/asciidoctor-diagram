require_relative 'converter'
require_relative '../extensions'
require_relative '../util/java'

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