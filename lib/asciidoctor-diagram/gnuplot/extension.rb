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
        
        if width.nil? or height.nil?
          code = "set term #{format}"
        else
          code = "set term #{format} size #{width},#{height}"
        end

        transparent = source.attr("transparent", nil, inherit_prefix)
        if !transparent.nil?
          if transparent == "true"          
            code << " transparent"
          else
            code << " notransparent"
          end
        end        

        crop = source.attr("crop", nil, inherit_prefix)

        if !crop.nil?
          if crop == "true"
            code << " crop"
          else
            code << " nocrop"
          end
        end

        font = source.attr("font", nil, inherit_prefix)
        if !font.nil?
          code << %( font "#{font}")
        end

        font_scale = source.attr("fontscale", nil, inherit_prefix)
        if !font_scale.nil?
          code << " fontscale #{font_scale}"
        end

        background = source.attr("background", nil, inherit_prefix)
        if !background.nil?
          code << %( background "#{background}")
        end
  
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
