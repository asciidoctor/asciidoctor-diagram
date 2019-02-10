require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    module Erd
      include CliGenerator

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            erd(source, f)
          end
        end
      end

      def erd(source, format)
        erd_path = source.find_command('erd')
        dot_path = source.find_command('dot', :alt_attrs => ['graphvizdot'])

        dot_code = generate_stdin(erd_path, format.to_s, source.to_s) do |tool_path, output_path|
          [tool_path, '-o', Platform.native_path(output_path), '-f', 'dot']
        end

        generate_stdin(dot_path, format.to_s, dot_code) do |tool_path, output_path|
          [tool_path, "-o#{Platform.native_path(output_path)}", "-T#{format.to_s}"]
        end
      end
    end

    class ErdBlockProcessor < Extensions::DiagramBlockProcessor
      include Erd
    end

    class ErdBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Erd
    end
  end
end
