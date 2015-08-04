require 'set'

require_relative '../extensions'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    module Ditaa
      JARS = ['ditaamini-0.10.jar'].map do |jar|
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

        OPTIONS = {
          'scale' => lambda { |o, v| o << '--scale' << v if v },
          'tabs' => lambda { |o, v| o << '--tabs' << v if v },
          'background' => lambda { |o, v| o << '--background' << v if v },
          'antialias' => lambda { |o, v| o << '--no-antialias' if v == 'false' },
          'separation' => lambda { |o, v| o  << '--no-separation' if v == 'false'},
          'round-corners' => lambda { |o, v| o  << '--round-corners' if v == 'true'},
          'shadows' => lambda { |o, v| o  << '--no-shadows' if v == 'false'},
          'debug' => lambda { |o, v| o  << '--debug' if v == 'true'},
          'fixed-slope' => lambda { |o, v| o  << '--fixed-slope' if v == 'true'},
          'transparent' => lambda { |o, v| o  << '--transparent' if v == 'true'}
        }

        def init_ditaa_options(parent, attributes)
          global_attributes = parent.document.attributes

          options = []

          OPTIONS.keys.each do |key|
            value = attributes.delete(key) || global_attributes["ditaa-option-#{key}"]
            OPTIONS[key].call(options, value)
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