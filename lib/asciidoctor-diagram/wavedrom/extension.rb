require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class WavedromBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter WavedromConverter
    end

    class WavedromBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter WavedromConverter
    end
  end
end
