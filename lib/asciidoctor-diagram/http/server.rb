require 'base64'
require 'json'
require 'sinatra/base'
require 'zlib'

require_relative '../diagram_source'
require_relative '../graphviz/converter'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    class Server < Sinatra::Base
      get '/:type/:format/:source' do
        type = params['type']
        accepts = lambda { |t| params['format'].downcase.to_sym == t }
        raw_source = params['source']
        decoded_source = Base64.urlsafe_decode64(raw_source)
        decompressed_source = Zlib::Inflate.inflate(decoded_source)
        source = decompressed_source
        render_diagram(type, accepts, source, {})
      end

      post '/' do
        params = JSON.parse(request.body.read)
        type = params['diagram_type']
        accepts = lambda { |t| params['output_format'].downcase.to_sym == t }
        source = params['diagram_source']
        render_diagram(type, accepts, source, {})
      end

      post '/:type' do
        type = params['type'].to_sym
        r = request
        accepts = lambda { |t| r.accept?(to_mime_type(t)) }
        source = request.body.read
        render_diagram(type, accepts, source, {})
      end

      post '/:type/:format' do
        type = params['type'].to_sym
        accepts = lambda { |t| params['format'].downcase.to_sym == t }
        source = request.body.read
        render_diagram(type, accepts, source, {})
      end

      def to_mime_type(type)
        case type
        when :pdf
          'application/pdf'
        when :png
          'image/png'
        when :svg
          'image/svg'
        when :txt
          'text/plain'
        else
          nil
        end
      end

      def get_converter(type)
        case type
        when :graphviz
          GraphvizConverter.new
        else
          nil
        end
      end

      def render_diagram(type, accepts, source, attributes)
        converter = get_converter(type.downcase.to_sym)
        return [500, "Unsupported diagram type #{type}"] unless converter

        format = converter.supported_formats.find {|f| accepts.call(f)}
        return [500, "Could not determine supported output format"] unless format

        source = ServerSource.new(type.downcase, source, attributes)
        options = converter.collect_options(source)
        diagram = converter.convert(source, format, options)

        content_type to_mime_type(format)
        diagram
      end
    end

    class ServerSource
      include Asciidoctor::Diagram::DiagramSource

      def initialize(name, source, attributes)
        @name = name
        @source = source
        @attributes = attributes
      end

      def diagram_type
        @name
      end

      def attr(name, default_value = nil, inherit = diagram_type)
        @attributes[name] || default_value
      end

      def base_dir
        nil
      end

      def load_code
        @source
      end

      def config
        {}
      end

      def find_command(cmd, options = nil)
        Asciidoctor::Diagram::Which.which(cmd, options)
      end

      def resolve_path(target, start = nil)
        target
      end

      def image_name
        "image"
      end

      def should_process?(image_file, image_metadata)
        true
      end
    end
  end
end