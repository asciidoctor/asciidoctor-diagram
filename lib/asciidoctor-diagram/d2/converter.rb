require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class D2Converter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:svg, :png, :pdf]
      end

      def collect_options(source)
        {
          :layout => source.attr('layout'),
          :theme => source.attr('theme'),
          :pad => source.attr('pad'),
          :animate_interval => source.attr('animate-interval'),
          :sketch => source.attr('sketch'),
          :font_regular => source.attr('font-regular'),
          :font_italic => source.attr('font-italic'),
          :font_bold => source.attr('font-bold')
        }
      end

      def convert(source, format, options)
        generate_file(source.find_command('d2'), "d2", format.to_s, source.code) do |tool_path, input_path, output_path|
          args = [tool_path, '--browser', 'false']

          options.each_pair do |key, value|
            flag = "--#{key.to_s.gsub('_', '-')}"

            if key == :sketch && !value.nil? && value != 'false'
              args << flag
            elsif key.to_s.start_with?('font') && !value.nil?
              args << Platform.native_path(value)
            elsif !value.nil?
              args << flag
              args << value
            end
          end

          args << Platform.native_path(input_path)
          args << Platform.native_path(output_path)

          {
            :args => args,
            :chdir => source.base_dir
          }
        end
      end
    end
  end
end
