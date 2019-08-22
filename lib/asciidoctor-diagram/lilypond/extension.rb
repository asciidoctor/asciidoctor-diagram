require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Lilypond
      include CliGenerator
      include Which

      def self.included(mod)
        [:png, :pdf].each do |f|
          mod.register_format(f, :image) do |parent, source|
            lilypond(parent, source, f)
          end
        end
      end

      def lilypond(parent, source, format)
        code = <<-EOF
\\paper{
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup=##f
  scoreTitleMarkup=##f
}

        EOF
        code << source.to_s

        inherit_prefix = name
        resolution = source.attr('resolution', nil, inherit_prefix)

        generate_stdin(which(parent, 'lilypond'), format.to_s, code) do |tool_path, output_path|
          args = [tool_path, '-daux-files=#f', '-dbackend=eps', '-dno-gs-load-fonts', '-dinclude-eps-fonts', '-o', Platform.native_path(output_path), '-f', format.to_s]

          args << '-dsafe'
          args << "-dresolution=#{resolution}" if resolution
          args << "-dpixmap-format=pngalpha" if format == :png

          args << '-'

          {
              :args => args,
              :out_file => "#{output_path}.#{format.to_s}"
          }
        end
      end
    end

    class LilypondBlockProcessor < Extensions::DiagramBlockProcessor
      include Lilypond
    end

    class LilypondBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Lilypond
    end
  end
end
