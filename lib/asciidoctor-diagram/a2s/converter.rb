require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class AsciiToSvgConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:svg]
      end

      def collect_options(source)
        options = {}
        options[:sx] = source.attr('scalex')
        options[:sy] = source.attr('scaley')
        options[:scale] = source.attr('scale')
        options[:noblur] = source.attr('noblur') == 'true'
        options[:font] = source.attr('fontfamily')
        options
      end

      def convert(source, format, options)
        sx = options[:sx]
        sy = options[:sy]
        scale = options[:scale]
        noblur = options[:noblur]
        font = options[:font]

        generate_stdin(source.find_command('a2s'), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, '-o', Platform.native_path(output_path)]

          if sx && sy
            args << '-s' << "#{sx},#{sy}"
          elsif scale
            args << '-s' << "#{scale},#{scale}"
          end

          if noblur
            args << '-b'
          end

          if font
            args << '-f' << font
          end

          args
        end
      end

      def native_scaling?
        true
      end
    end
  end
end
