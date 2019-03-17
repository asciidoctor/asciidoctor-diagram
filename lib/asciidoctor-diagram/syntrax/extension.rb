require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class SyntraxBlockProcessor < DiagramBlockProcessor
      use_converter SyntraxConverter
    end

    class SyntraxBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SyntraxConverter
    end
  end
end
