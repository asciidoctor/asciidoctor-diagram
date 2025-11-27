require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class VhsConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:gif, :svg] # svg requires https://github.com/agentstation/vhs, mp4 works too but fails in tests
      end

      def collect_options(source)
        {}
      end

      def convert(source, format, options)
        # vhs executes terminal commands, so it should only run in UNSAFE mode
        document = source.instance_variable_get(:@parent_block).document
        safe_mode = document.safe
        
        if safe_mode >= Asciidoctor::SafeMode::SAFE
          raise "vhs diagram generation is not allowed in safe mode #{safe_mode}. vhs executes terminal commands and requires UNSAFE mode (0)."
        end
        
        generate_file(source.find_command('vhs'), 'tape', format.to_s, source.code) do |tool_path, input_path, output_path|
          {
            :args => [tool_path, Platform.native_path(input_path), '-o', Platform.native_path(output_path)],
            :chdir => source.base_dir,
            :encoding => Encoding::ASCII_8BIT
          }
        end
      end
    end
  end
end

