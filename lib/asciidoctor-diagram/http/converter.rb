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
      DEFAULT_MAX_GET_SIZE = 1024

      include DiagramConverter

      def initialize(base_uri, type, converter)
        @base_uri = base_uri
        @type = type
        @converter = converter
      end

      def supported_formats
        @converter.supported_formats
      end

      def collect_options(source)
        options = {}

        options[:max_get_size] = source.global_attr('max-get-size', DEFAULT_MAX_GET_SIZE).to_i

        options
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

          path = uri.path.dup
          path << '/' unless path.end_with? '/'
          path << format.to_s
        when :kroki_io
          compressed = Zlib.deflate(code, Zlib::BEST_COMPRESSION)
          data = Base64.urlsafe_encode64(compressed)

          path = uri.path.dup
          path << '/' unless path.end_with? '/'
          path << source.diagram_type.to_s
          path << '/' << format.to_s
        else
          raise "Unsupported server type: " + @type
        end

        get_path = path.dup << '/' << data

        if get_path.length > options[:max_get_size]
          uri.path = path
          get_uri(uri, code, 'text/plain; charset=utf-8')
        else
          uri.path = get_path
          get_uri(uri)
        end
      end

      private

      def get_uri(uri, post_data = nil, post_content_type = nil, attempt = 1)
        if attempt >= 10
          raise "Too many redirects"
        end

        if post_data.nil?
          request = Net::HTTP::Get.new(uri.path)
        else
          request = Net::HTTP::Post.new(uri.path)
          request.body = post_data
          request.set_content_type(post_content_type) if post_content_type
        end

        Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme.downcase == 'https') do |http|
          response = http.request(request)
          case response
            when Net::HTTPSuccess
              response.body
            when Net::HTTPRedirection then
              location = response['Location']
              new_uri = URI.parse(location)
              if new_uri.relative?
                resolved_uri = uri + location
              else
                resolved_uri = new_uri
              end

              get_uri(resolved_uri, post_data, post_content_type, attempt + 1)
            else
              response.value
          end
        end
      end
    end
  end
end
