require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class GraphvizPyBlockProcessor < DiagramBlockProcessor
      use_converter GraphvizPyConverter
    end

    class GraphvizPyBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter GraphvizPyConverter
    end

    class GraphvizPyInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter GraphvizPyConverter
    end
  end
end
