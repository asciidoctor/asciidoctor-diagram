require_relative '../diagram_converter'
require 'delegate'
require 'uri'

module Asciidoctor
  module Diagram
    # @private
    class PlantUmlConverter
      include DiagramConverter

      CLASSPATH_ENV = Java.environment_variable('DIAGRAM_PLANTUML_CLASSPATH')
      LIB_DIR = File.expand_path('../..', File.dirname(__FILE__))
      PLANTUML_JARS = if CLASSPATH_ENV
                        CLASSPATH_ENV.split(File::PATH_SEPARATOR)
                      else
                        begin
                          require 'asciidoctor-diagram/plantuml/classpath'
                          ::Asciidoctor::Diagram::PlantUmlClasspath::JAR_FILES
                        rescue LoadError
                          nil
                        end
                      end

      if PLANTUML_JARS
        Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
        Java.classpath.concat PLANTUML_JARS
      end

      def wrap_source(source)
        PlantUMLPreprocessedSource.new(source, self)
      end

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        options = {
            :size_limit => source.attr('size-limit', '4096')
        }

        theme = source.attr('theme', nil)
        options[:theme] = theme if theme

        options
      end

      def should_preprocess(source)
        source.attr('preprocess', 'true') == 'true'
      end

      def add_common_headers(headers, source)
        base_dir = source.base_dir

        config_file = source.attr('plantumlconfig', nil, true) || source.attr('config')
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, base_dir)
        end

        headers['X-PlantUML-Basedir'] = Platform.native_path(File.expand_path(base_dir))

        include_dir = source.attr('includedir')
        if include_dir
          headers['X-PlantUML-IncludeDir'] = Platform.native_path(File.expand_path(include_dir, base_dir))
        end
      end

      def add_theme_header(headers, theme)
        headers['X-PlantUML-Theme'] = theme if theme
      end

      def add_size_limit_header(headers, limit)
        headers['X-PlantUML-SizeLimit'] = limit if limit
      end

      def convert(source, format, options)
        unless PLANTUML_JARS
          raise "Could not load PlantUML. Either require 'asciidoctor-diagram-plantuml' or specify the location of the PlantUML JAR(s) using the 'DIAGRAM_PLANTUML_CLASSPATH' environment variable."
        end
        Java.load

        code = source.code

        case format
        when :png
          mime_type = 'image/png'
        when :svg
          mime_type = 'image/svg+xml'
        when :txt, :utxt
          mime_type = 'text/plain;charset=utf-8'
        when :atxt
          mime_type = 'text/plain'
        else
          raise "Unsupported format: #{format}"
        end

        headers = {
            'Accept' => mime_type
        }

        unless should_preprocess(source)
          add_common_headers(headers, source)
        end

        add_theme_header(headers, options[:theme])
        add_size_limit_header(headers, options[:size_limit])

        dot = source.find_command('dot', :alt_attrs => ['graphvizdot'], :raise_on_error => false)
        if dot
          headers['X-Graphviz'] = ::Asciidoctor::Diagram::Platform.host_os_path(dot)
        end

        response = Java.send_request(
            :url => '/plantuml',
            :body => code,
            :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("PlantUML image generation failed", response)
        end

        response[:body]
      end
    end

    class UmlConverter < PlantUmlConverter
      def self.tag
        'uml'
      end
    end

    class SaltConverter < PlantUmlConverter
      def self.tag
        'salt'
      end
    end

    class PlantUMLPreprocessedSource < SimpleDelegator
      def initialize(source, converter)
        super(source)
        @converter = converter
      end

      def code
        @code ||= load_code
      end

      def load_code
        Java.load

        code = __getobj__.code

        tag = @converter.class.tag
        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index("@start") && code.index("@end")

        if @converter.should_preprocess(self)
          headers = {}
          @converter.add_common_headers(headers, self)
          @converter.add_theme_header(headers, @converter.collect_options(self)[:theme])

          response = Java.send_request(
            :url => '/plantumlpreprocessor',
            :body => code,
            :headers => headers
          )

          unless response[:code] == 200
            raise Java.create_error("PlantUML preprocessing failed", response)
          end

          code = response[:body]
          code.force_encoding(Encoding::UTF_8)
        end

        code
      end
    end
  end
end
