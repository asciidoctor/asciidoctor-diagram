require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class VegaConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg, :png]
      end


      def collect_options(source)
        {
            :vegalite => source.diagram_type.to_s.include?('lite') || source.attr('vegalite')
        }
      end

      def convert(source, format, options)
        base_dir = source.base_dir

        code = source.to_s

        if code.include?('/schema/vega-lite/') || options[:vegalite]
          vega_code = generate_stdin_stdout(source.find_command("vl2vg"), code)
        else
          vega_code = code
        end

        generate_stdin_stdout(source.find_command("vg2#{format}"), vega_code) do |tool_path|
          args = [tool_path, '--base', Platform.native_path(base_dir)]
          if format == :svg
            args << '--header'
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
