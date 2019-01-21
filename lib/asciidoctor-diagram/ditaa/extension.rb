require 'set'

require_relative '../extensions'
require_relative 'converter'

module Asciidoctor
  module Diagram
    module Ditaa
      OPTION_KEYS = DitaaConverter::OPTIONS.keys

      def self.included(mod)
        mod.register_format(:png, :image) do |parent, source|
          ditaa(parent, source, 'image/png')
        end

        mod.register_format(:svg, :image) do |parent, source|
          ditaa(parent, source, 'image/svg+xml')
        end
      end

      def ditaa(parent, source, mime_type)
        global_attributes = parent.document.attributes
        opts = {}
        opts['mime_type'] = mime_type
        OPTION_KEYS.each do |key|
          value = source.attributes.delete(key) || global_attributes["ditaa-option-#{key}"]
          opts[key] = value if value
        end
        DitaaConverter.convert(source.to_s, opts)
      end
    end

    class DitaaBlockProcessor < Extensions::DiagramBlockProcessor
      include Ditaa
    end

    class DitaaBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Ditaa
    end
  end
end