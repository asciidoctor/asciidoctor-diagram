require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class GnuplotConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg, :gif, :txt, :literal]
      end

      def collect_options(source, name)
        {
            :width => source.attr('width', nil, name),
            :height => source.attr('height', nil, name),
            :transparent => source.attr('transparent', nil, name),
            :crop => source.attr('crop', nil, name),
            :font => source.attr('font', nil, name),
            :fontscale => source.attr('fontscale', nil, name),
            :background => source.attr('background', nil, name),
        }
      end

      def convert(source, format, options)
        if format == :txt || format == :literal
          terminal = 'dumb'
        else
          terminal = format.to_s
        end
        code = "set term #{terminal}"

        width = options[:width]
        height = options[:height]
        code << " size #{width},#{height}" unless width.nil? or height.nil?

        transparent = options[:transparent]
        code << (transparent ? " transparent" : " notransparent") unless transparent.nil?

        crop = options[:crop]
        code << (crop ? " crop" : " nocrop") unless crop.nil?

        font = options[:font]
        code << %( font "#{font}") unless font.nil?

        font_scale = options[:fontscale]
        code << " fontscale #{font_scale}" unless font_scale.nil?

        background = options[:background]
        code << %( background "#{background}") unless background.nil?

        code << "\n"
        code << source.to_s

        generate_stdin_stdout(source.find_command('gnuplot'), code)
      end
    end
  end
end
