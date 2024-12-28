require_relative '../diagram_converter'
require_relative '../util/cli'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class PintoraConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        options = {}

        options[:width] = source.attr('width')
        options[:theme] = source.attr('theme')
        options[:background_color] = source.attr('background-color')
        options[:pixel_ratio] = source.attr('pixel-ratio')

        options
      end

      def convert(source, format, options)
        pintora = source.find_command('pintora')

        generate_file(pintora, 'pintora', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          args = [tool_path, 'render', '-i', Platform.native_path(input_path), '-o', Platform.native_path(output_path)]


          if options[:width]
            args << '-w' << options[:width]
          end

          if options[:theme]
            args << '-t' << options[:theme]
          end

          if options[:pixel_ratio]
            args << '-p' << options[:pixel_ratio]
          end

          if options[:background_color]
            args << '-b' << options[:background_color]
          end

          {
            :args => args,
            :chdir => source.base_dir
          }
        end
      end
    end
  end
end
