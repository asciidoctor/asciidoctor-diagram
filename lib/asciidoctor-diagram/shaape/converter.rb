require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class ShaapeConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end


      def convert(source, format, options)
        generate_stdin(source.find_command('shaape'), format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, '-o', Platform.native_path(output_path), '-t', format.to_s, '-']
        end
      end
    end
  end
end
