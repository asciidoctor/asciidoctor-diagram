require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class UmletBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter UmletConverter
    end

    class UmletBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter UmletConverter
    end
  end
end
