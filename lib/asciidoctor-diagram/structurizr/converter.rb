require 'set'

require_relative '../diagram_converter'
require_relative '../diagram_processor'
require_relative '../plantuml/converter'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    class StructurizrConverter < PlantUmlConverter

      CLASSPATH_ENV = 'DIAGRAM_STRUCTURIZR_CLASSPATH'
      CLI_HOME_ENV = 'DIAGRAM_STRUCTURIZRCLI_HOME'
      STRUCTURIZR_JARS = if ENV.has_key?(CLASSPATH_ENV)
                           ENV[CLASSPATH_ENV].split(File::PATH_SEPARATOR)
                         elsif ENV.has_key?(CLI_HOME_ENV)
                           lib_dir = File.expand_path('lib', ENV[CLI_HOME_ENV])
                           Dir.children(lib_dir).select { |c| c.end_with? '.jar' }.map { |c| File.expand_path(c, lib_dir) }
                         else
                           raise "Could not load Structurizr. Specify the location of the Structurizr JAR(s) using the 'DIAGRAM_STRUCTURIZRCLI_HOME' or DIAGRAM_STRUCTURIZR_CLASSPATH' environment variable."
                         end

      Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')]
      Java.classpath.concat STRUCTURIZR_JARS

      def supported_formats
        [:txt]
      end

      def collect_options(source)
        {
          :view => source.attr('view')
        }
      end

      def convert(source, format, options)
        Java.load

        headers = {
          'Accept' => 'text/x-plantuml-c4'
        }
        headers['X-Structurizr-View'] = options[:view] if options[:view]

        response = Java.send_request(
          :url => '/structurizr',
          :body => source.to_s,
          :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("Structurizr code generation failed", response)
        end

        response[:body].force_encoding(Encoding::UTF_8)
      end
    end

    class StructurizrToPlantUMLSource < SimpleDelegator
      def initialize(source, converter)
        super(source)
        @converter = converter
      end

      def code
        @code ||= load_code
      end

      def load_code
        Java.load

        headers = {
          'Accept' => 'text/x-plantuml-c4'
        }

        view = attr('view')
        headers['X-Structurizr-View'] = view if view

        response = Java.send_request(
          :url => '/structurizr',
          :body => source.to_s,
          :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("Structurizr code generation failed", response)
        end

        response[:body].force_encoding(Encoding::UTF_8)
      end
    end
  end
end
