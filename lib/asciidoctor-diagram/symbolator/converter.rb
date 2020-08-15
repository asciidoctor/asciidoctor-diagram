require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class SymbolatorConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:png, :pdf, :svg]
      end

      def convert(source, format, options)
        generate_stdin(source.find_command('symbolator'), format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, "-i-", "-o#{Platform.native_path(output_path)}", "-f#{format.to_s}"]
        end
      end
    end
  end
end
