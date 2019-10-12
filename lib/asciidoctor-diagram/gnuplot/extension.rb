require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class GnuplotBlockProcessor < DiagramBlockProcessor
      use_converter GnuplotConverter
    end

    class GnuplotBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter GnuplotConverter
    end
  end
end
