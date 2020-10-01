require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class TikZConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:pdf, :svg]
      end

      def collect_options(source)
        {
            :preamble => source.attr('preamble') == 'true'
        }
      end

      def convert(source, format, options)
        latexpath = source.find_command('pdflatex')

        if format == :svg
          svgpath = source.find_command('pdf2svg')
        else
          svgpath = nil
        end

        if options[:preamble]
          preamble, body = source.to_s.split(/^~~~~$/, 2)
          unless body
            body = preamble
            preamble = ''
          end
        else
          preamble = ''
          body = source.to_s
        end

        latex = <<'END'
\documentclass[border=2bp, tikz]{standalone}
\usepackage{tikz}
END
        latex << preamble
        latex << <<'END'
\begin{document}
\begingroup
\tikzset{every picture/.style={scale=1}}
END
        latex << body
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
            [tool_path, Platform.native_path(input_path), Platform.native_path(output_path)]
          end
        else
          pdf
        end
      end
    end
  end
end
