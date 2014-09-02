require_relative '../extensions'
require_relative '../util/cli_generator'

module Asciidoctor
  module Diagram
    # @private
    module Shaape
      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            CliGenerator.generate('shaape', p, c.to_s) do |tool_path, output_path|
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