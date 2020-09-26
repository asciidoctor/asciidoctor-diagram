require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class MscgenConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        {:font => source.attr('font')}
      end

      def convert(source, format, options)
        font = options[:font]

        generate_stdin(source.find_command('mscgen'), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, '-o', Platform.native_path(output_path), '-T', format.to_s]
          if font
            args << '-F' << font
          end
          args << '-'
          args
        end
      end
    end
  end
end
