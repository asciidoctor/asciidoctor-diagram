require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class BytefieldConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def convert(source, format, options)
        bytefield_path = source.find_command('bytefield-svg')

        generate_stdin(bytefield_path, format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, "--output", Platform.native_path(output_path)]
        end
      end
    end
  end
end
