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
          mod.register_format(f, :image) do |c, p|
            mermaid = which(p, 'mermaid')

            seq_config = c.attributes['sequenceConfig'] || p.attr('sequenceConfig')
            if seq_config
              seq_config = p.normalize_system_path(seq_config, p.document.base_dir)
            end

            width = c.attributes['width']

            CliGenerator.generate_file(mermaid, c.to_s) do |tool_path, input_path, output_path|
              output_dir = File.dirname(output_path)
              output_file = File.expand_path(File.basename(input_path) + ".#{f.to_s}", output_dir)

              args = [tool_path, "--#{f.to_s}", '-o', output_dir]

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