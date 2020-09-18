require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class PikchrConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def convert(source, format, options)
        pikchr_path = source.find_command('pikchr')

        generate_file_stdout(pikchr_path, format.to_s, source.to_s) do |tool_path, input_path|
          [tool_path, "--svg-only", input_path]
        end
      end
    end
  end
end
