require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class OxdrawConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:svg, :png]
      end

      def native_scaling?
        true
      end

      def collect_options(source)
        {
          :background => source.attr('background'),
          :scale => source.attr('scale')
        }
      end

      def convert(source, format, options)
        data = generate_stdin(source.find_command('oxdraw'), format.to_s, source.code) do |tool_path, output_path|
          args = [tool_path]

          options.each_pair do |key, value|
            unless value.nil?
              args << "--#{key.to_s.gsub('_', '-')}"
              args << value
            end
          end

          args << '--input'
          args << '-'
          args << '--output'
          args << Platform.native_path(output_path)
          args << '--output-format'
          args << format.to_s
          args << '--quiet'

          {
            :args => args,
            :chdir => source.base_dir
          }
        end

        # oxdraw doesn't perform scaling for SVG files, so we have to do it ourselves since we claim to support native
        # scaling
        if format == :svg && options[:scale]
          scale = options[:scale].to_f
          data.sub!(/(<svg.*width=")([0-9]+)(".*>)/) { |_| $1 + ($2.to_i * scale).to_i.to_s + $3 }
          data.sub!(/(<svg.*height=")([0-9]+)(".*>)/) { |_| $1 + ($2.to_i * scale).to_i.to_s + $3 }
        end

        data
      end
    end
  end
end
