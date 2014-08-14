require 'tempfile'

require_relative '../util/java'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    module CliGenerator
      def self.generate(tool, parent, code)
        tool_var = '@' + tool

        tool_path = instance_variable_get(tool_var)
        unless tool_path
          tool_path = parent.document.attributes[tool]
          tool_path = ::Asciidoctor::Diagram.which(tool) unless tool_path && File.executable?(tool_path)
          raise "Could not find the '#{tool}' executable in PATH; add it to the PATH or specify its location using the 'shaape' document attribute" unless tool_path
          instance_variable_set(tool_var, tool_path)
        end

        target_file = Tempfile.new(tool)
        begin
          target_file.close

          args = yield tool_path, target_file.path

          IO.popen(args, "w") do |io|
            io.write code
          end
          result_code = $?

          raise "#{tool} image generation failed" unless result_code == 0

          File.read(target_file.path)
        ensure
          target_file.unlink
        end
      end
    end
  end
end
