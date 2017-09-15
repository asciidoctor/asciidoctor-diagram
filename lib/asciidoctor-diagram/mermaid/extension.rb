require_relative '../extensions'
require_relative '../util/cli'
require_relative '../util/cli_generator'
require_relative '../util/platform'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module Mermaid
      include CliGenerator
      include Which

      def self.included(mod)
        [:png, :svg].each do |f|
          mod.register_format(f, :image) do |parent, source|
            mermaid(parent, source, f)
          end
        end
      end

      def mermaid(parent_block, source, format)
        inherit_prefix = name
        mermaid = which(parent_block, 'mermaid')
        config['mermaid>=6'] ||= ::Asciidoctor::Diagram::Cli.run(mermaid, '--version').split('.')[0].to_i >= 6
        # Mermaid >= 6.0.0 requires PhantomJS 2.1; older version required 1.9
        phantomjs = which(parent_block, 'phantomjs', :alt_attrs => [config['mermaid>=6'] ? 'phantomjs_2' : 'phantomjs_19'])

        css = source.attr('css', nil, inherit_prefix)
        if css
          css = parent_block.normalize_system_path(css, source.base_dir)
        end

        gantt_config = source.attr('ganttConfig', nil, inherit_prefix) || source.attr('ganttconfig', nil, inherit_prefix)
        if gantt_config
          gantt_config = parent_block.normalize_system_path(gantt_config, source.base_dir)
        end

        seq_config = source.attr('sequenceConfig', nil, inherit_prefix) || source.attr('sequenceconfig', nil, inherit_prefix)
        if seq_config
          seq_config = parent_block.normalize_system_path(seq_config, source.base_dir)
        end

        width = source.attr('width', nil, inherit_prefix)

        generate_file(mermaid, 'mmd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          output_dir = File.dirname(output_path)
          output_file = File.expand_path(File.basename(input_path) + ".#{format.to_s}", output_dir)

          args = [tool_path, '--phantomPath', Platform.native_path(phantomjs), "--#{format.to_s}", '-o', Platform.native_path(output_dir)]

          if css
            args << '--css' << Platform.native_path(css)
          end

          if gantt_config
            args << '--gantt_config' << Platform.native_path(gantt_config)
          end

          if seq_config
            args << '--sequenceConfig' << Platform.native_path(seq_config)
          end

          if width
            args << '--width' << width
          end

          args << Platform.native_path(input_path)

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
