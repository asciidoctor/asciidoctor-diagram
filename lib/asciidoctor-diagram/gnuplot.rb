require 'asciidoctor/extensions'
require_relative 'gnuplot/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::GnuplotBlockProcessor, :gnuplot
  block_macro Asciidoctor::Diagram::GnuplotBlockMacroProcessor, :gnuplot
  inline_macro Asciidoctor::Diagram::GnuplotInlineMacroProcessor, :gnuplot
end
