require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class DbmlConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def convert(source, format, options)
        generate_stdin_stdout(source.find_command('dbml-renderer'), source.code)
      end
    end
  end
end
