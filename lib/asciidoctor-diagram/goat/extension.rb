require_relative "converter"
require_relative "../diagram_processor"

module Asciidoctor
  module Diagram
    class GoATBlockProcessor < DiagramBlockProcessor
      use_converter GoATConverter
    end

    class GoATBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter GoATConverter
    end

    class GoATInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter GoATConverter
    end
  end
end
