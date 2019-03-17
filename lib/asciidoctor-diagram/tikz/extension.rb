require_relative '../diagram_processor'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class TikZBlockProcessor < DiagramBlockProcessor
      use_converter TikZConverter
    end

    class TikZBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter TikZConverter
    end
  end
end
