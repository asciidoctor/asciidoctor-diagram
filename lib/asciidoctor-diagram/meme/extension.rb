require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    module MemeProcessor
      def create_source(parent, target, attributes)
        attributes = attributes.dup
        attributes['background'] = apply_target_subs(parent, target)
        ::Asciidoctor::Diagram::ReaderSource.new(self, parent, '', attributes)
      end
    end
    
    class MemeBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter MemeConverter
      name_positional_attributes %w(top bottom target format)
      include MemeProcessor
    end

    class MemeInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter MemeConverter
      name_positional_attributes %w(top bottom target format)
      include MemeProcessor
    end
  end
end
