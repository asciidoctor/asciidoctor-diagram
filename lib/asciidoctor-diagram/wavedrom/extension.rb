require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Wavedrom
      include Which

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |c, p|
            wavedrom_cli = which(p, 'wavedrom', :raise_on_error => false)
            phantomjs = which(p, 'phantomjs', :raise_on_error => false)

            if wavedrom_cli && phantomjs
              CliGenerator.generate_file(wavedrom_cli, f.to_s, c.to_s) do |tool_path, input_path, output_path|
                [phantomjs, tool_path, '-i', input_path, "-#{f.to_s[0]}", output_path]
              end
            else
              if ::Asciidoctor::Diagram::Platform.os == :macosx
                wavedrom = which(p, 'WaveDromEditor.app', :attr_names => ['wavedrom'], :path => ['/Applications'])
                if wavedrom
                  wavedrom = File.join(wavedrom, 'Contents/MacOS/nwjs')
                end
              else
                wavedrom = which(p, 'WaveDromEditor', :attr_names => ['wavedrom'])
              end

              CliGenerator.generate_file(wavedrom, f.to_s, c.to_s) do |tool_path, input_path, output_path|
                [tool_path, 'source', input_path, f.to_s, output_path]
              end
            end
          end
        end
      end
    end

    class WavedromBlockProcessor < Extensions::DiagramBlockProcessor
      include Wavedrom
    end

    class WavedromBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Wavedrom
    end
  end
end