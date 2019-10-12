require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class WavedromConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end


      def convert(source, format, options)
        wavedrom_cli = source.find_command('wavedrom-cli', :raise_on_error => false)
        if wavedrom_cli
          generate_file(wavedrom_cli, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            [Platform.native_path(tool_path), '--input', Platform.native_path(input_path), "--#{format.to_s}", Platform.native_path(output_path)]
          end
        else
          wavedrom_cli = source.find_command('wavedrom', :raise_on_error => false)
          phantomjs = source.find_command('phantomjs', :alt_attrs => ['phantomjs_2'], :raise_on_error => false)

          if wavedrom_cli && !wavedrom_cli.include?('WaveDromEditor') && phantomjs
            generate_file(wavedrom_cli, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
              [phantomjs, Platform.native_path(tool_path), '-i', Platform.native_path(input_path), "-#{format.to_s[0]}", Platform.native_path(output_path)]
            end
          else
            if ::Asciidoctor::Diagram::Platform.os == :macosx
              wavedrom = source.find_command('WaveDromEditor.app', :alt_cmds => ['wavedrom-editor.app'], :attrs => ['WaveDromEditorApp'], :path => ['/Applications'])
              if wavedrom
                wavedrom = File.join(wavedrom, 'Contents/MacOS/nwjs')
              end
            else
              wavedrom = source.find_command('WaveDromEditor')
            end

            generate_file(wavedrom, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
              [tool_path, 'source', Platform.native_path(input_path), format.to_s, Platform.native_path(output_path)]
            end
          end
        end
      end
    end
  end
end
