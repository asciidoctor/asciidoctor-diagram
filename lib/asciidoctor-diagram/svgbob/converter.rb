require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class SvgbobConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:svg]
      end

      def native_scaling?
        true
      end

      OPTIONS = {
          :font_family => lambda { |o, v| o << '--font-family' << v if v },
          :font_size => lambda { |o, v| o << '--font-size' << v if v },
          :stroke_width => lambda { |o, v| o << '--stroke-width' << v if v },
          :scale => lambda { |o, v| o << '--scale' << v if v }
      }

      def collect_options(source)
        options = {}

        OPTIONS.keys.each do |option|
          attr_name = option.to_s.tr('_', '-')
          options[option] = source.attr(attr_name) || source.attr(attr_name, nil, 'svgbob-option')
        end

        options
      end


      def convert(source, format, options)

        flags = []
        options.each do |option, value|
          OPTIONS[option].call(flags, value)
        end
        
        generate_stdin(source.find_command('svgbob'), format.to_s, source.to_s) do |tool_path, output_path|
          ([tool_path, '-o', Platform.native_path(output_path)] + flags)
        end
      end
    end
  end
end
