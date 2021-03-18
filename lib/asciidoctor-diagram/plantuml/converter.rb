require_relative '../diagram_converter'
require 'delegate'
require 'uri'

module Asciidoctor
  module Diagram
    # @private
    class PlantUmlConverter
      include DiagramConverter

      CLASSPATH_ENV = 'DIAGRAM_PLANTUML_CLASSPATH'
      LIB_DIR = File.expand_path('../..', File.dirname(__FILE__))
      PLANTUML_JARS = if ENV.has_key?(CLASSPATH_ENV)
                        ENV[CLASSPATH_ENV].split(File::PATH_SEPARATOR)
                      else
                        begin
                          require 'asciidoctor-diagram/plantuml/classpath'
                          ::Asciidoctor::Diagram::PlantUmlClasspath::JAR_FILES
                        rescue LoadError
                          raise "Could not load PlantUML. Eiter require 'asciidoctor-diagram-plantuml' or specify the location of the PlantUML JAR(s) using the 'DIAGRAM_PLANTUML_CLASSPATH' environment variable."
                        end
                      end

      Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
      Java.classpath.concat PLANTUML_JARS

      def wrap_source(source)
        PlantUMLPreprocessedSource.new(source, self.class.tag)
      end

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        {
            :size_limit => source.attr('size-limit', '4096')
        }
      end

      def convert(source, format, options)
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

        size_limit = options[:size_limit]
        if size_limit
          headers['X-PlantUML-SizeLimit'] = size_limit
        end

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
      def initialize(source, tag)
        super(source)
        @tag = tag
      end

      def code
        @code ||= load_code
      end

      def load_code
        Java.load

        code = __getobj__.code

        code = "@start#{@tag}\n#{code}\n@end#{@tag}" unless code.index("@start") && code.index("@end")

        headers = {}

        config_file = attr('plantumlconfig', nil, true) || attr('config')
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, base_dir)
        end

        headers['X-PlantUML-Basedir'] = Platform.native_path(File.expand_path(base_dir))

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

        code
      end
    end
  end
end
