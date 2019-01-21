require_relative '../util/java'

module Asciidoctor
  module Diagram
    module DitaaConverter
      OPTIONS = {
        'scale' => ->(o, v) { o << '--scale' << v if v  },
        'tabs' => ->(o, v) { o << '--tabs' << v if v },
        'background' => ->(o, v) { o << '--background' << v if v },
        'antialias' => ->(o, v) { o << '--no-antialias' if v == 'false' },
        'separation' => ->(o, v) { o << '--no-separation' if v == 'false' },
        'round-corners' => ->(o, v) { o << '--round-corners' if v == 'true' },
        'shadows' => ->(o, v) { o << '--no-shadows' if v == 'false' },
        'debug' => ->(o, v) {o << '--debug' if v == 'true' },
        'fixed-slope' => ->(o, v) { o << '--fixed-slope' if v == 'true' },
        'transparent' => ->(o, v) { o << '--transparent' if v == 'true' }
      }.freeze

      JARS = %w[ditaa-1.3.13.jar ditaamini-0.11.jar].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def self.convert(source, opts)
        Java.load
        headers = {
          Accept: opts['mime_type'],
          'X-Options' =>  to_header_options(opts)
        }
        send_request(source, headers)
      end

      def self.to_header_options opts
        options = []
        OPTIONS.keys.each do |key|
          value = opts[key]
          OPTIONS[key].call(options, value)
        end
        options.join(' ')
      end

      def self.send_request(body, headers, url = '/ditaa')
        response = Java.send_request(
          url:  url,
          body: body,
          headers: headers
        )
        unless response[:code] == 200
          raise Java.create_error("Ditaa image generation failed", response)
        end
        response[:body]
      end
    end
  end
end