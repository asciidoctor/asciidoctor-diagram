require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

require 'base64'
require 'net/http'
require 'uri'
require 'zlib'

module Asciidoctor
  module Diagram
    # @private
    class HttpConverter
      include DiagramConverter

      def initialize(base_uri, type, converter)
        @base_uri = base_uri
        @type = type
        @converter = converter
      end

      def supported_formats
        @converter.supported_formats
      end

      def collect_options(source, name)
        {
            :block_name => name
        }
      end

      def convert(source, format, options)
        code = source.code

        uri = URI(@base_uri)

        case @type
        when :plantuml
          deflate = Zlib::Deflate.new(Zlib::BEST_COMPRESSION,
                                      -Zlib::MAX_WBITS,
                                      Zlib::MAX_MEM_LEVEL,
                                      Zlib::DEFAULT_STRATEGY)

          compressed = deflate.deflate(code, Zlib::FINISH)
          deflate.close

          encoded = Base64.urlsafe_encode64(compressed)
          data = '0A' + encoded

          path = uri.path
          path << '/' unless path.end_with? '/'
          path << format.to_s
          path << '/' << data
          uri.path = path
        when :kroki_io
          compressed = Zlib.deflate(code, Zlib::BEST_COMPRESSION)
          data = Base64.urlsafe_encode64(compressed)

          path = uri.path
          path << '/' unless path.end_with? '/'
          path << options[:block_name].to_s
          path << '/' << format.to_s
          path << '/' << data
          uri.path = path
        else
          raise "Unsupported server type: " + @type
        end

        get_uri(uri)
      end

      private

      def get_uri(uri, attempt = 1)
        if attempt >= 10
          raise "Too many redirects"
        end

        Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme.downcase == 'https') do |http|
          response = http.request_get uri.path
          case response
            when Net::HTTPSuccess
              response.body
            when Net::HTTPRedirection then
              location = response['Location']
              new_uri = URI.parse(location)
              if new_uri.relative?
                get_uri(uri + location, attempt + 1)
              else
                get_uri(new_uri, attempt + 1)
              end
            else
              response.value
          end
        end
      end
    end
  end
end
