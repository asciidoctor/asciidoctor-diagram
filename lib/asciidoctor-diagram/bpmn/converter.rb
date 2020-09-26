require_relative '../diagram_converter'
require_relative '../util/cli'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class BpmnConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg, :pdf, :jpeg]
      end

      def collect_options(source)
        options = {}

        options[:width] = source.attr('width')
        options[:height] = source.attr('height')

        options
      end

      def convert(source, format, options)
        opts = {}

        opts[:width] = options[:width]

        bpmnjs = source.find_command('bpmn-js')
        opts[:height] = options[:height]
        opts[:theme] = options[:theme]
        config = options[:config]
        if config
          opts[:config] = source.resolve_path(config)
        end
        run_bpmnjs(bpmnjs, source, format, opts)
      end

      private

      def run_bpmnjs(bpmnjs, source, format, options = {})
        generate_file(bpmnjs, 'bpmn', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          args = [tool_path, Platform.native_path(input_path), '-o', Platform.native_path(output_path), '-t', format.to_s]


          if options[:width]
            args << '--width' << options[:width]
          end

          if options[:height]
            args << '--height' << options[:height]
          end

          args
        end
      end
    end
  end
end
