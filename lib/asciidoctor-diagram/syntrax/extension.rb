require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    class SyntraxBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter SyntraxConverter
    end

    class SyntraxBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter SyntraxConverter
    end
  end
end
