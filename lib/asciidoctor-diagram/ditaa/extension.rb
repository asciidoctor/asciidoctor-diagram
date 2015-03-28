require_relative '../extensions'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    module Ditaa
      JARS = ['ditaamini0_9.jar'].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def ditaa(code, attrs)
        Java.load

        response = Java.send_request(
            :url => '/ditaa',
            :body => code,
            :headers => {
                'X-Options' => attrs.delete('options') || ''
            }
        )

        unless response[:code] == 200
          raise "Ditaa image generation failed: #{response[:reason]} #{response[:body]}"
        end

        response[:body]
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |c, _, attrs|
          ditaa(c.to_s, attrs)
        end
      end

      def create_source(parent, reader, attributes)
        source = super(parent, reader, attributes)
        source.extend DitaaSource
        source
      end

      module DitaaSource
        def should_process?(image_file, image_metadata)
          super(image_file, image_metadata) || image_metadata['options'] != attributes['options']
        end

        def create_image_metadata
          metadata = super
          metadata['options'] = attributes['options']
          metadata
        end
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