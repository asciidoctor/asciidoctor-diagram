require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class DpicConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def convert(source, format, options)
        dpic_path = source.find_command('dpic')

        code = source.to_s
        code.prepend ".PS\n" unless code.start_with?(".PS\n")
        code << "\n.PE" unless code.start_with?("\n.PE")

        generate_file_stdout(dpic_path, format.to_s, code) do |tool_path, input_path|
          [tool_path, "-v", "-z", input_path]
        end
      end
    end
  end
end
