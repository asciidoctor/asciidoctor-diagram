require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class OxdrawBlockProcessor < DiagramBlockProcessor
      use_converter OxdrawConverter
    end

    class OxdrawBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter OxdrawConverter
    end

    class OxdrawInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter OxdrawConverter
    end
  end
end
