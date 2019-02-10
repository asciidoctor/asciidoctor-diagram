require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class NomnomlBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter NomnomlConverter
    end

    class NomnomlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter NomnomlConverter
    end
  end
end
