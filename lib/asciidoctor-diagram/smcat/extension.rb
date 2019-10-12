require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class SmcatBlockProcessor < DiagramBlockProcessor
      use_converter SmcatConverter
    end

    class SmcatBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter SmcatConverter
    end
  end
end
