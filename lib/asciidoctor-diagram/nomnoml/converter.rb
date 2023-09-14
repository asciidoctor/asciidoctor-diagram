require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class NomnomlConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end


      def convert(source, format, options)
        generate_file(source.find_command('nomnoml'), 'nomnoml', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          {
            :args => [tool_path, Platform.native_path(input_path), Platform.native_path(output_path)],
            :chdir => source.base_dir
          }
        end
      end
    end
  end
end
