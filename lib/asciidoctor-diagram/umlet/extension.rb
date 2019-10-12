require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class UmletBlockProcessor < DiagramBlockProcessor
      use_converter UmletConverter
    end

    class UmletBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter UmletConverter
    end
  end
end
