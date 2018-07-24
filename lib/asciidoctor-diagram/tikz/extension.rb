require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module TikZ
      include CliGenerator
      include Which

      def self.included(mod)
        [:pdf, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            tikz(parent, source, f)
          end
        end
      end

      def tikz(parent, source, format)
        latexpath = which(parent, 'pdflatex')

        if format == :svg
          svgpath = which(parent, 'pdf2svg')
        else
          svgpath = nil
        end

        latex = <<'END'
\documentclass[border=2bp]{standalone}
\usepackage{tikz}
\begin{document}
\begingroup
\tikzset{every picture/.style={scale=1}}
END
        latex << source.to_s
        latex << <<'END'
\endgroup
\end{document}
END

        pdf = generate_file(latexpath, 'tex', 'pdf', latex) do |tool_path, input_path, output_path|
          {
              :args => [tool_path, '-shell-escape', '-file-line-error', '-interaction=nonstopmode', '-output-directory', Platform.native_path(File.dirname(output_path)), Platform.native_path(input_path)],
              :out_file => "#{File.dirname(input_path)}/#{File.basename(input_path, '.*')}.pdf"
          }
        end

        if svgpath
          generate_file(svgpath, 'pdf', 'svg', pdf) do |tool_path, input_path, output_path|
            [tool_path, Platform.native_path(File.dirname(input_path)), Platform.native_path(File.dirname(output_path))]
          end
        else
          pdf
        end
      end
    end

    class TikZBlockProcessor < Extensions::DiagramBlockProcessor
      include TikZ
    end

    class TikZBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include TikZ
    end
  end
end
