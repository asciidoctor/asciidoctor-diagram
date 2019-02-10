require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class ErdConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end

      def convert(source, format, options)
        erd_path = source.find_command('erd')
        dot_path = source.find_command('dot', :alt_attrs => ['graphvizdot'])

        dot_code = generate_stdin(erd_path, format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, '-o', Platform.native_path(output_path), '-f', 'dot']
        end

        generate_stdin(dot_path, format.to_s, dot_code) do |tool_path, output_path|
          [tool_path, "-o#{Platform.native_path(output_path)}", "-T#{format.to_s}"]
        end
      end
    end
  end
end
