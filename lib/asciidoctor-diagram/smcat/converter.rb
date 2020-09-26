require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class SmcatConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def collect_options(source)
        {
            :direction => source.attr('direction'),
            :engine => source.attr('engine')
        }
      end

      def convert(source, format, options)
        direction = options[:direction]
        engine = options[:engine]

        generate_stdin(source.find_command('smcat'), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, '-o', Platform.native_path(output_path), '-T', format.to_s]
          if direction
            args << '-d' << direction
          end

          if engine
            args << '-E' << engine
          end

          args << '-'
          args
        end
      end
    end
  end
end
