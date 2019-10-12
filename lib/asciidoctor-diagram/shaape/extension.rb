require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class ShaapeBlockProcessor < DiagramBlockProcessor
      use_converter ShaapeConverter
    end

    class ShaapeBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter ShaapeConverter
    end
  end
end
