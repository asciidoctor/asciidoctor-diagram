require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class SyntraxConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        {
            :heading => source.attr('heading'),
            :scale => source.attr('scale'),
            :transparent => source.attr('transparent'),
            :style => source.attr('style-file')
        }
      end

      def convert(source, format, options)
        generate_file(source.find_command('syntrax'), 'spec', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          args = [tool_path, '-i', Platform.native_path(input_path), '-o', Platform.native_path(output_path)]

          title = options[:heading]
          if title
            args << '--title' << title
          end

          scale = options[:scale]
          if scale
            args << '--scale' << scale
          end

          transparent = options[:transparent]
          if transparent == 'true'
            args << '--transparent'
          end
          style = options[:style]
          if style
            args << '--style' << style
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
