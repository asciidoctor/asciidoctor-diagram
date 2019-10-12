require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Gnuplot
      include CliGenerator
      include Which

      def self.included(mod)
        [:png, :svg, :gif].each do |f|
          mod.register_format(f, :image) do |parent, source|
            gnuplot(parent, source, f)
          end
        end

        mod.register_format(:txt, :literal) do |parent, source|
            gnuplot(parent, source, :txt)
        end          
      end

      def gnuplot(parent, source, format)
        inherit_prefix = name        
        
        width = source.attr("width", nil, inherit_prefix)
        height = source.attr("height", nil, inherit_prefix)

        if format == :txt
          format = 'dumb'
        end

        code = "set term #{format}"
        code << " size #{width},#{height}" unless width.nil? or height.nil?

        transparent = source.attr("transparent", nil, inherit_prefix)
        code << (transparent ? " transparent" : " notransparent") unless transparent.nil?

        crop = source.attr("crop", nil, inherit_prefix)
        code << (crop ? " crop" : " nocrop") unless crop.nil?

        font = source.attr("font", nil, inherit_prefix)
        code << %( font "#{font}") unless font.nil?

        font_scale = source.attr("fontscale", nil, inherit_prefix)
        code << " fontscale #{font_scale}" unless font_scale.nil?

        background = source.attr("background", nil, inherit_prefix)
        code << %( background "#{background}") unless background.nil?
  
        code << "\n"
        code << source.to_s 
        generate_stdin_stdout(which(parent, 'gnuplot'), code) do |tool_path|
          [tool_path]
        end
 
      end
    end

    class GnuplotBlockProcessor < Extensions::DiagramBlockProcessor
      include Gnuplot
    end

    class GnuplotBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Gnuplot
    end
  end
end
