require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Nomnoml
      include CliGenerator
      include Which

      def self.included(mod)
        [:svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            nomnoml(parent, source, f)
          end
        end
      end

      def nomnoml(parent, source, format)
        generate_file(which(parent, 'nomnoml'), 'nomnoml', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          [tool_path, Platform.native_path(input_path), Platform.native_path(output_path)]
        end
      end
    end

    class NomnomlBlockProcessor < Extensions::DiagramBlockProcessor
      include Nomnoml
    end

    class NomnomlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Nomnoml
    end
  end
end
