require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class BytefieldBlockProcessor < DiagramBlockProcessor
      use_converter BytefieldConverter
    end

    class BytefieldBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter BytefieldConverter
    end
  end
end
