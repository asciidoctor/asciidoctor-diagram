require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class PenroseConverter
      include DiagramConverter
      include CliGenerator

      def supported_formats
        [:svg]
      end

      def collect_options(source)
        {
            :domain => source.attr('domain_file'),
            :style => source.attr('style_file'),
            :variation => source.attr('variation')
        }
      end

      def convert(source, format, options)
        domain_path = options[:domain]
        raise "Domain file is required" unless domain_path
        style_path = options[:style]
        raise "Style file is required" unless style_path
        variation = options[:variation]

        generate_file(source.find_command('roger'), 'substance', format.to_s, source.to_s) do |tool_path, source_path, output_path|
          args = [tool_path, 'trio', '-o', Platform.native_path(output_path)]

          args << "-v" << variation if variation

          args << "--path"
          args << "/"

          args << "--trio"
          args << Platform.native_path(source_path)
          args << Platform.native_path(source.resolve_path(domain_path))
          args << Platform.native_path(source.resolve_path(style_path))
          args << "--"

          args
        end        
      end
    end
  end
end
