require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class SymbolatorBlockProcessor < DiagramBlockProcessor
      use_converter SymbolatorConverter
    end

    class SymbolatorBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SymbolatorConverter
    end
  end
end
