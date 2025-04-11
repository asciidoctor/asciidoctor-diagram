require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    class PlantUmlNative
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        {
          :theme => source.attr('theme'),
        }
      end

      def convert(source, format, options)
        generate_stdin_stdout(source.find_command('plantuml'), source.code) do |tool_path|
          args = [tool_path, '-pipe']

          options.each_pair do |key, value|
            flag = "-#{key.to_s.gsub('_', '-')}"

            if !value.nil?
              args << flag
              args << value
            end
          end

          {
            :args => args,
            :chdir => source.base_dir
          }
        end
      end
    end
  end
end
