require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Smcat
      include CliGenerator
      include Which

      def self.included(mod)
        [:svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            smcat(parent, source, f)
          end
        end
      end

      def smcat(parent, source, format)
        generate_stdin(which(parent, 'smcat'), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, '-o', Platform.native_path(output_path), '-T', format.to_s]
          args << '-'
          args
        end
      end
    end

    class SmcatBlockProcessor < Extensions::DiagramBlockProcessor
      include Smcat
    end

    class SmcatBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Smcat
    end
  end
end
