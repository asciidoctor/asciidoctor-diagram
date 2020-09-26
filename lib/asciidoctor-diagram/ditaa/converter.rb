require 'set'

require_relative '../diagram_converter'
require_relative '../diagram_processor'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    class DitaaConverter
      include DiagramConverter

      OPTIONS = {
          :scale => lambda { |o, v| o << '--scale' << v if v },
          :tabs => lambda { |o, v| o << '--tabs' << v if v },
          :background => lambda { |o, v| o << '--background' << v if v },
          :antialias => lambda { |o, v| o << '--no-antialias' if v == 'false' },
          :separation => lambda { |o, v| o  << '--no-separation' if v == 'false'},
          :round_corners => lambda { |o, v| o  << '--round-corners' if v == 'true'},
          :shadows => lambda { |o, v| o  << '--no-shadows' if v == 'false'},
          :debug => lambda { |o, v| o  << '--debug' if v == 'true'},
          :fixed_slope => lambda { |o, v| o  << '--fixed-slope' if v == 'true'},
          :transparent => lambda { |o, v| o  << '--transparent' if v == 'true'}
      }

      JARS = ['ditaa-1.3.15.jar', 'ditaamini-0.12.jar'].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS


      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        options = {}
        
        OPTIONS.keys.each do |option|
          attr_name = option.to_s.tr('_', '-')
          options[option] = source.attr(attr_name) || source.attr(attr_name, nil, 'ditaa-option')
        end
        
        options
      end

      def native_scaling?
        true
      end

      def convert(source, format, options)
        Java.load

        flags = []

        options.each do |option, value|
          OPTIONS[option].call(flags, value)
        end

        options_string = flags.join(' ')

        case format
        when :png
          mime_type = 'image/png'
        when :svg
          mime_type = 'image/svg+xml'
        else
          raise "Unsupported format: #{format}"
        end

        headers = {
            'Accept' => mime_type,
            'X-Options' => options_string
        }

        response = Java.send_request(
            :url => '/ditaa',
            :body => source.to_s,
            :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("Ditaa image generation failed", response)
        end

        response[:body]
      end
    end
  end
end