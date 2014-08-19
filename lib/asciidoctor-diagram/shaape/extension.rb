require_relative '../util/cli_generator'
require_relative '../util/diagram'

module Asciidoctor
  module Diagram
    module Shaape
      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            CliGenerator.generate('shaape', p, c) do |tool_path, output_path|
              [tool_path, '-o', output_path, '-t', f.to_s, '-']
            end
          end
        end
      end
    end

    class ShaapeBlockProcessor < DiagramBlockProcessor
      include Shaape
    end

    class ShaapeBlockMacroProcessor < DiagramBlockMacroProcessor
      include Shaape
    end
  end
end