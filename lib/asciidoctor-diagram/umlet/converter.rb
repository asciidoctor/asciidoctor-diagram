require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class UmletConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg, :png, :pdf, :gif]
      end

      def convert(source, format, options)
        generate_file(source.find_command('umlet'), 'uxf', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          [tool_path, '-action=convert', "-format=#{format.to_s}", "-filename=#{Platform.native_path(input_path)}", "-output=#{Platform.native_path(output_path)}"]
        end
      end
    end
  end
end
