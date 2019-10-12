require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class MscBlockProcessor < DiagramBlockProcessor
      use_converter MscgenConverter
    end

    class MscBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter MscgenConverter
    end
  end
end
