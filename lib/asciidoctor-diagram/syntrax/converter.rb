require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class SyntraxConverter
      include DiagramConverter
      include CliGenerator

      CLASSPATH_ENV = Java.environment_variable('DIAGRAM_JSYNTRAX_CLASSPATH')
      CLI_HOME_ENV = Java.environment_variable('DIAGRAM_JSYNTRAX_HOME')
      JSYNTRAX_JARS = if CLASSPATH_ENV
                           CLASSPATH_ENV.split(File::PATH_SEPARATOR)
                         elsif CLI_HOME_ENV
                           lib_dir = File.expand_path('lib', CLI_HOME_ENV)
                           Dir.children(lib_dir).select { |c| c.end_with? '.jar' }.map { |c| File.expand_path(c, lib_dir) }
                         else
                           nil
                         end

      if JSYNTRAX_JARS
        Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')]
        Java.classpath.concat JSYNTRAX_JARS
      end

      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        {
            :heading => source.attr('heading'),
            :scale => source.attr('scale'),
            :transparent => source.attr('transparent'),
            :style => source.attr('style-file') || source.attr("#{source.diagram_type}-style", nil, true)
        }
      end

      def convert(source, format, options)
        shared_args = []
        title = options[:heading]
        if title
          shared_args << '--title' << title
        end

        scale = options[:scale]
        if scale
          shared_args << '--scale' << scale
        end

        transparent = options[:transparent]
        if transparent == 'true'
          shared_args << '--transparent'
        end
        style = options[:style]
        if style
          shared_args << '--style' << style
        end

        if JSYNTRAX_JARS
          Java.load

          options_string = shared_args.join(' ')

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
            :url => '/syntrax',
            :body => source.to_s,
            :headers => headers
          )

          unless response[:code] == 200
            raise Java.create_error("JSyntrax code generation failed", response)
          end

          response[:body]
        else
          generate_file(source.find_command('syntrax'), 'spec', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            [tool_path, '-i', Platform.native_path(input_path), '-o', Platform.native_path(output_path)] + shared_args
          end
        end

      end

      def native_scaling?
        true
      end
    end
  end
end
