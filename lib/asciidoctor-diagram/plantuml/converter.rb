require_relative '../diagram_converter'
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

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        {
            :config => source.attr('plantumlconfig', nil, true) || source.attr('config'),
            :size_limit => source.attr('size_limit', '4096')
        }
      end

      def convert(source, format, options)
        Java.load

        code = preprocess_code(source, self.class.tag)

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

        config_file = options[:config]
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, source.base_dir)
        end

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

      def preprocess_code(source, tag)
        code = source.to_s

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index("@start") && code.index("@end")

        code.gsub!(/(?<=<img:)[^>]+(?=>)/) do |match|
          resolve_path(match, source, source.attr('imagesdir', nil, false))
        end

        code.gsub!(/(?:(?<=!include\s)|(?<=!includesub\s))\s*[^<][^!\n\r]+/) do |match|
          resolve_path(match.lstrip, source, source.base_dir)
        end

        code
      end

      def resolve_path(path, source, base_dir)
        if path =~ ::URI::ABS_URI
          uri = ::URI.parse(path)
          if uri.scheme == 'file'
            source.resolve_path(uri.path, base_dir)
          else
            path
          end
        else
          source.resolve_path(path, base_dir)
        end
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
  end
end
