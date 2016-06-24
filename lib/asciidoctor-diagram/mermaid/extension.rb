require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Mermaid
      include Which

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            mermaid(parent, source, f)
          end
        end
      end

      def mermaid(parent, source, format)
        mermaid = which(parent, 'mermaid')
        @is_mermaid_v6 ||= `#{mermaid} --version`.split('.')[0].to_i >= 6
        # Mermaid >= 6.0.0 requires PhantomJS 2.1; older version required 1.9
        phantomjs = which(parent, 'phantomjs', :alt_attrs => [@is_mermaid_v6 ? 'phantomjs_2' : 'phantomjs_19'])

        seq_config = source.attr('sequenceConfig', nil, true)
        if seq_config
          seq_config = parent.normalize_system_path(seq_config, source.base_dir)
        end

        width = source.attr('width')

        CliGenerator.generate_file(mermaid, 'mmd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          output_dir = File.dirname(output_path)
          output_file = File.expand_path(File.basename(input_path) + ".#{format.to_s}", output_dir)

          args = [tool_path, '--phantomPath', phantomjs, "--#{format.to_s}", '-o', output_dir]

          if seq_config
            args << '--sequenceConfig' << seq_config
          end

          if width
            args << '--width' << width
          end

          args << input_path

          {
              :args => args,
              :out_file => output_file
          }
        end
      end
    end

    class MermaidBlockProcessor < Extensions::DiagramBlockProcessor
      include Mermaid
    end

    class MermaidBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Mermaid
    end
  end
end