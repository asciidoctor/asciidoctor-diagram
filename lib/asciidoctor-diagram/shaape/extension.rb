require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Shaape
      include Which

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            CliGenerator.generate(which(p, 'shaape'), c.to_s) do |tool_path, output_path|
              [tool_path, '-o', output_path, '-t', f.to_s, '-']
            end
          end
        end
      end
    end

    class ShaapeBlockProcessor < Extensions::DiagramBlockProcessor
      include Shaape
    end

    class ShaapeBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Shaape
    end
  end
end