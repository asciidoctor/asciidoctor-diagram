require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class WavedromBlockProcessor < DiagramBlockProcessor
      use_converter WavedromConverter
    end

    class WavedromBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter WavedromConverter
    end
  end
end
