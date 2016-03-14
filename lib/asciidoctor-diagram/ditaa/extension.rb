require 'set'

require_relative '../extensions'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    module Ditaa
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

      JARS = ['ditaamini-0.10.jar'].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def self.included(mod)
        mod.register_format(:png, :image) do |parent, source|
          ditaa(parent, source)
        end
      end

      def ditaa(parent, source)
        Java.load

        global_attributes = parent.document.attributes

        options = []

        OPTIONS.keys.each do |key|
          value = source.attributes.delete(key) || global_attributes["ditaa-option-#{key}"]
          OPTIONS[key].call(options, value)
        end

        options = options.join(' ')

        response = Java.send_request(
            :url => '/ditaa',
            :body => source.to_s,
            :headers => {
                'X-Options' => options
            }
        )

        unless response[:code] == 200
          raise Java.create_error("Ditaa image generation failed", response)
        end

        response[:body]
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