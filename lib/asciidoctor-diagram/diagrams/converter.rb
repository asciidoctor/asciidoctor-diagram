require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require_relative '../util/platform'

module Asciidoctor
  module Diagram
    # @private
    class DiagramsConverter
      include DiagramConverter
      include CliGenerator


      def supported_formats
        [:png, :svg, :pdf]
      end

      def convert(source, format, options)
        python_path = source.find_command('python3', :attrs => ['diagrams-python'], :alt_cmds => ['python'])

        code = source.to_s

        match_data = /Diagram\((.*?)\)/.match(code)
        raise "Could not find Diagram constructor" unless match_data

        args = match_data[1].strip

        target_file = Tempfile.new('diagrams')

        diagram = 'Diagram('
        diagram << args
        diagram << ',' unless args.empty?
        diagram << "filename=\"#{target_file.path}\""
        diagram << ",outformat=\"#{format}\""
        diagram << ')'

        code = match_data.pre_match + diagram + match_data.post_match

        begin
          target_file.close
          generate_stdin_file(python_path, code, target_file.path + ".#{format}") do |tool|
            [tool, '-']
          end
        ensure
          target_file.unlink
        end
      end
    end
  end
end
