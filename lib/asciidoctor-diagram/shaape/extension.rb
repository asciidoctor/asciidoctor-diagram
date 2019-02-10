require_relative 'converter'
require_relative '../extensions'

module Asciidoctor
  module Diagram
    class ShaapeBlockProcessor < Extensions::DiagramBlockProcessor
      use_converter ShaapeConverter
    end

    class ShaapeBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      use_converter ShaapeConverter
    end
  end
end
