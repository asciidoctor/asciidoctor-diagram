require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    module Svgbob
      include CliGenerator

      def self.included(mod)
        [:svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            svgbob(source, f)
          end
        end
      end

      def svgbob(source, format)
        generate_stdin(source.find_command('svgbob'), format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, '-o', Platform.native_path(output_path)]
        end
      end
    end

    class SvgBobBlockProcessor < Extensions::DiagramBlockProcessor
      include Svgbob
    end

    class SvgBobBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Svgbob
    end
  end
end
