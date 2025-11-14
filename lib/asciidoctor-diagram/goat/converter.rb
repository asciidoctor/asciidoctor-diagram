require_relative "../diagram_converter"
require_relative "../util/cli_generator"
require_relative "../util/platform"

module Asciidoctor
  module Diagram
    # @private
    class GoATConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:svg]
      end

      def collect_options(source)
        {
          sds: source.attr("svg-color-dark-scheme"),
          sls: source.attr("svg-color-light-scheme"),
        }
      end

      def convert(source, format, options)
        sds, sls = options.values_at(:sds, :sls)
        generate_stdin_stdout(source.find_command("goat"), source.code) do |tool|
          args = [tool]
          args.push("-sds", sds) if sds
          args.push("-sls", sls) if sls
          {
            args: args,
            chdir: source.base_dir,
          }
        end
      end
    end
  end
end
