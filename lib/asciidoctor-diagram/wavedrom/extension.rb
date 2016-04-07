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
          mod.register_format(f, :image) do |parent, source|
            wavedrom(parent, source, f)
          end
        end
      end

      def wavedrom(parent, source, format)
        wavedrom_cli = which(parent, 'wavedrom', :raise_on_error => false)
        phantomjs = which(parent, 'phantomjs', :raise_on_error => false)

        if wavedrom_cli && !wavedrom_cli.include?('WaveDromEditor') && phantomjs
          CliGenerator.generate_file(wavedrom_cli, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            [phantomjs, tool_path, '-i', input_path, "-#{format.to_s[0]}", output_path]
          end
        else
          if ::Asciidoctor::Diagram::Platform.os == :macosx
            wavedrom = which(parent, 'WaveDromEditor.app', :alt_attrs => ['wavedrom'], :path => ['/Applications'])
            if wavedrom
              wavedrom = File.join(wavedrom, 'Contents/MacOS/nwjs')
            end
          else
            wavedrom = which(parent, 'WaveDromEditor', :alt_attrs => ['wavedrom'])
          end

          CliGenerator.generate_file(wavedrom, 'wvd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
            [tool_path, 'source', input_path, format.to_s, output_path]
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