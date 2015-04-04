require 'set'

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

      def ditaa(code, source)
        Java.load

        response = Java.send_request(
            :url => '/ditaa',
            :body => code,
            :headers => {
                'X-Options' => source.options
            }
        )

        unless response[:code] == 200
          raise "Ditaa image generation failed: #{response[:reason]} #{response[:body]}"
        end

        response[:body]
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |c, _, source|
          ditaa(c.to_s, source)
        end
      end

      def create_source(parent, reader, attributes)
        source = super(parent, reader, attributes)
        source.extend DitaaSource

        source.init_ditaa_options(parent, attributes)

        source
      end

      module DitaaSource
        attr_reader :options

        def init_ditaa_options(parent, attributes)
          global_attributes = parent.document.attributes

          option_values = {}

          ['scale', 'antialias', 'separation', 'round-corners', 'shadows', 'debug'].each do |key|
            option_values[key] = attributes.delete(key) || global_attributes["ditaa-option-#{key}"]
          end

          options = []

          begin
          options << '--scale' << option_values['scale'] if option_values['scale']
          options << '--no-antialias' if option_values['antialias'] == 'false'
          options << '--no-separation' if option_values['separation'] == 'false'
          options << '--round-corners' if option_values['round-corners'] == 'true'
          options << '--no-shadows' if option_values['shadows'] == 'false'
          options << '--debug' if option_values['debug'] == 'true'
          rescue => e
            e.backtrace.each { |l| puts l }
          end

          @options = options.join(' ')
        end

        def should_process?(image_file, image_metadata)
          super(image_file, image_metadata) || image_metadata['options'] != @options
        end

        def create_image_metadata
          metadata = super
          metadata['options'] = @options
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