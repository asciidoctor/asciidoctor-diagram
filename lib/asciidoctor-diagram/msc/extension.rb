require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    module Mscgen
      include CliGenerator

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            mscgen(source, f)
          end
        end
      end

      def mscgen(source, format)
        inherit_prefix = name
        font = source.attr('font', nil, inherit_prefix)

        generate_stdin(source.find_command('mscgen'), format.to_s, source.to_s) do |tool_path, output_path|
          args = [tool_path, '-o', Platform.native_path(output_path), '-T', format.to_s]
          if font
            args << '-F' << font
          end
          args << '-'
          args
        end
      end
    end

    class MscBlockProcessor < Extensions::DiagramBlockProcessor
      include Mscgen
    end

    class MscBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Mscgen
    end
  end
end
