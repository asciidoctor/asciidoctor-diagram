require_relative '../diagram_converter'
require_relative '../util/cli'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class MermaidConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg]
      end

      def collect_options(source, name)
        options = {}

        options[:css] = source.attr('css', nil, name)
        options[:gantt_config] = source.attr('ganttConfig', nil, name) || source.attr('ganttconfig', nil, name)
        options[:seq_config] = source.attr('sequenceConfig', nil, name) || source.attr('sequenceconfig', nil, name)
        options[:width] = source.attr('width', nil, name)
        options[:height] = source.attr('height', nil, name)
        options[:theme] = source.attr('theme', nil, name)
        options[:background] = source.attr('background', nil, name)
        options[:config] = source.attr('config', nil, name) || source.attr('config', nil, name)

        options
      end

      def convert(source, format, options)
        opts = {}

        css = options[:css]
        if css
          opts[:css] = source.resolve_path(css)
        end

        gantt_config = options[:gantt_config]
        if gantt_config
          opts[:gantt] = source.resolve_path(gantt_config)
        end

        seq_config = opts[:seq_config]
        if seq_config
          opts[:sequence] = source.resolve_path(seq_config)
        end

        opts[:width] = options[:width]

        mmdc = source.find_command('mmdc', :raise_on_error => false)
        if mmdc
          opts[:height] = options[:height]
          opts[:theme] = options[:theme]
          opts[:background] = options[:background]
          config = options[:config]
          if config
            opts[:config] = source.resolve_path(config)
          end
          run_mmdc(mmdc, source, format, opts)
        else
          mermaid = source.find_command('mermaid')
          run_mermaid(mermaid, source, format, opts)
        end
      end

      private
      def run_mmdc(mmdc, source, format, options = {})
        generate_file(mmdc, 'mmd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          args = [tool_path, '-i', Platform.native_path(input_path), '-o', Platform.native_path(output_path)]

          if options[:css]
            args << '--cssFile' << Platform.native_path(options[:css])
          end

          if options[:theme]
            args << '--theme' << options[:theme]
          end

          if options[:width]
            args << '--width' << options[:width]
          end

          if options[:height]
            args << '--height' << options[:height]
          end

          if options[:background]
            bg = options[:background]
            bg = "##{bg}" unless bg[0] == '#'
            args << '--backgroundColor' << bg
          end

          if options[:config]
            args << '--configFile' << Platform.native_path(options[:config])
          elsif options[:gantt] || options[:sequence]
            mermaidConfig = []

            if options[:gantt]
              mermaidConfig << "\"gantt\": #{File.read(options[:gantt])}"
            end

            if options[:sequence]
              configKey = config['mmdcSequenceConfigKey'] ||= begin
                version_parts = ::Asciidoctor::Diagram::Cli.run(mmdc, '--version')[:out].split('.').map { |p| p.to_i }
                major = version_parts[0] || 0
                minor = version_parts[1] || 0
                patch = version_parts[2] || 0
                if major > 0 || (major == 0 && minor > 4) || (major == 0 && minor == 4 && patch > 1)
                  'sequence'
                else
                  'sequenceDiagram'
                end
              end
              mermaidConfig << "\"#{configKey}\": #{File.read(options[:sequence])}"
            end

            config_file = "#{input_path}.json"

            File.write(config_file, "{#{mermaidConfig.join ','}}")

            args << '--configFile' << Platform.native_path(config_file)
          end

          args
        end
      end

      def run_mermaid(mermaid, source, format, options = {})
        config['mermaid>=6'] ||= ::Asciidoctor::Diagram::Cli.run(mermaid, '--version')[:out].split('.')[0].to_i >= 6
        # Mermaid >= 6.0.0 requires PhantomJS 2.1; older version required 1.9
        phantomjs = source.find_command('phantomjs', :alt_attrs => [config['mermaid>=6'] ? 'phantomjs_2' : 'phantomjs_19'])

        generate_file(mermaid, 'mmd', format.to_s, source.to_s) do |tool_path, input_path, output_path|
          output_dir = File.dirname(output_path)
          output_file = File.expand_path(File.basename(input_path) + ".#{format.to_s}", output_dir)

          args = [tool_path, '--phantomPath', Platform.native_path(phantomjs), "--#{format.to_s}", '-o', Platform.native_path(output_dir)]

          if options[:css]
            args << '--css' << Platform.native_path(options[:css])
          end

          if options[:gantt]
            args << '--gantt_config' << Platform.native_path(options[:gantt])
          end

          if options[:sequence]
            args << '--sequenceConfig' << Platform.native_path(options[:sequence])
          end

          if options[:width]
            args << '--width' << options[:width]
          end

          args << Platform.native_path(input_path)

          {
              :args => args,
              :out_file => output_file
          }
        end
      end
    end
  end
end
