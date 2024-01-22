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
        wavedrom = source.find_command('wavedrom-cli', :attrs => ['wavedrom'], :raise_on_error => false)

        unless wavedrom
          wavedrom = source.find_command('wavedrom', :raise_on_error => false)
        end

        unless wavedrom
          if ::Asciidoctor::Diagram::Platform.os == :macosx
            wavedrom = source.find_command('WaveDromEditor.app', :alt_cmds => ['wavedrom-editor.app'], :attrs => ['WaveDromEditorApp'], :path => ['/Applications'], :raise_on_error => false)
            if wavedrom
              wavedrom = File.join(wavedrom, 'Contents/MacOS/nwjs')
            end
          else
            wavedrom = source.find_command('WaveDromEditor', :raise_on_error => false)
          end
        end

        unless wavedrom
          source.find_command('wavedrom-cli', :attrs => ['wavedrom'])
        end

        if wavedrom.end_with?('-cli')
          generate_file(wavedrom, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            {
              :args => [Platform.native_path(tool_path), '--input', Platform.native_path(input_path), "--#{format.to_s}", Platform.native_path(output_path)],
              :chdir => source.base_dir
            }
          end
        elsif wavedrom.include?('WaveDromEditor')
          generate_file(wavedrom, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            {
              :args => [tool_path, 'source', Platform.native_path(input_path), format.to_s, Platform.native_path(output_path)],
              :chdir => source.base_dir
            }
          end
        else
          phantomjs = source.find_command('phantomjs', :alt_attrs => ['phantomjs_2'])
          generate_file(wavedrom, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            {
              :args => [phantomjs, Platform.native_path(tool_path), '-i', Platform.native_path(input_path), "-#{format.to_s[0]}", Platform.native_path(output_path)],
              :chdir => source.base_dir
            }
          end
        end
      end
    end
  end
end
