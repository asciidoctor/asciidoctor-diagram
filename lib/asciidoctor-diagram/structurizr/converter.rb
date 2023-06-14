require 'set'

require_relative '../diagram_converter'
require_relative '../diagram_processor'
require_relative '../plantuml/converter'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    class StructurizrConverter
      include DiagramConverter

      CLASSPATH_ENV = Java.environment_variable('DIAGRAM_STRUCTURIZR_CLASSPATH')
      CLI_HOME_ENV = Java.environment_variable('DIAGRAM_STRUCTURIZRCLI_HOME')
      STRUCTURIZR_JARS = if CLASSPATH_ENV
                           CLASSPATH_ENV.split(File::PATH_SEPARATOR)
                         elsif CLI_HOME_ENV
                           lib_dir = File.expand_path('lib', CLI_HOME_ENV)
                           Dir[File.join(lib_dir, '*.jar')]
                         else
                           nil
                         end

      if STRUCTURIZR_JARS
        Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')]
        Java.classpath.concat STRUCTURIZR_JARS
      end

      def supported_formats
        [:txt]
      end

      def collect_options(source)
        {
          :view => source.attr('view'),
          :renderer => Renderers.get_renderer_type(source)
        }
      end

      def convert(source, format, options)
        unless STRUCTURIZR_JARS
          raise "Could not load Structurizr. Specify the location of the Structurizr JAR(s) using the 'DIAGRAM_STRUCTURIZRCLI_HOME' or DIAGRAM_STRUCTURIZR_CLASSPATH' environment variable."
        end

        Java.load

        headers = {
          'Accept' => Renderers.mime_type(options[:renderer])
        }
        headers['X-Structurizr-View'] = options[:view] if options[:view]

        response = Java.send_request(
          :url => '/structurizr',
          :body => source.code,
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
