require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class MscBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter MscgenConverter
    end

    class MscBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter MscgenConverter
    end
  end
end
