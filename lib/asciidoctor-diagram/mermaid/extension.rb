require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class MermaidBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter MermaidConverter
    end

    class MermaidBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter MermaidConverter
    end
  end
end
