require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    ['BlockDiag', 'SeqDiag', 'ActDiag', 'NwDiag', 'RackDiag', 'PacketDiag'].each do |name|
      converter = Class.new do
        include DiagramConverter
        include CliGenerator

        def supported_formats
          [:png, :pdf, :svg]
        end

        def convert(source, format, options)
          # On Debian based systems the Python 3.x packages python3-(act|block|nw|seq)diag executables with
          # a '3' suffix.
          cmd_name = self.class.const_get(:TOOL)
          alt_cmd_name = "#{cmd_name}3"

          font_path = source.attr('fontpath')

          generate_stdin(source.find_command(cmd_name, :alt_cmds => [alt_cmd_name]), format.to_s, source.to_s) do |tool_path, output_path|
            args = [tool_path, '-a', '-o', Platform.native_path(output_path), "-T#{format.to_s}"]
            args << "-f#{Platform.native_path(font_path)}" if font_path
            args << '-'
            args
          end
        end
      end
      converter.const_set(:TOOL, name.downcase)

      ::Asciidoctor::Diagram.const_set("#{name}Converter", converter)
    end
  end
end
