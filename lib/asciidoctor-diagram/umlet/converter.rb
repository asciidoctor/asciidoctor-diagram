require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/java'

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
        java = ::Asciidoctor::Diagram::Java.java

        umlet = source.find_command('umlet')
        ext = File.extname(umlet)
        if ext == '' || ext != '.jar'
          umlet = File.expand_path(File.basename(umlet, '.*') + '.jar', File.dirname(umlet))
        end

        generate_file(java, 'uxf', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          [tool_path, '-jar', Platform.native_path(umlet), '-action=convert', "-format=#{format.to_s}", "-filename=#{Platform.native_path(input_path)}", "-output=#{Platform.native_path(output_path)}"]
        end
      end
    end
  end
end
