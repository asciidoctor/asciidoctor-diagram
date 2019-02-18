require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class TikZBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter TikZConverter
    end

    class TikZBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter TikZConverter
    end
  end
end
