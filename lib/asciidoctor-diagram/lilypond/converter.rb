require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class LilypondConverter
      include DiagramConverter
      include CliGenerator

      EXTRA_PATH = []

      if ::Asciidoctor::Diagram::Platform.os == :macosx
        lilypond_app = ::Asciidoctor::Diagram::Which.which('LilyPond.app', :path => ['/Applications'])
        if lilypond_app
          EXTRA_PATH << File.join(lilypond_app, 'Contents/Resources/bin')
        end
      end

      EXTRA_PATH.freeze

      def supported_formats
        [:png, :pdf]
      end

      def collect_options(source)
        {
            :resolution => source.attr('resolution')
        }
      end

      def convert(source, format, options)
        code = <<-EOF
\\paper{
  oddFooterMarkup=##f
  oddHeaderMarkup=##f
  bookTitleMarkup=##f
  scoreTitleMarkup=##f
}

        EOF
        code << source.to_s

        resolution = options[:resolution]

        generate_stdin(source.find_command('lilypond', :path => EXTRA_PATH), format.to_s, code) do |tool_path, output_path|
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
  end
end
