require 'tempfile'

module Asciidoctor
  module Diagram
    # @private
    module CliGenerator
      def self.generate(tool, code)
        tool_name = File.basename(tool)

        target_file = Tempfile.new(tool_name)
        begin
          target_file.close

          args = yield tool, target_file.path

          IO.popen(args, "w") do |io|
            io.write code
          end
          result_code = $?

          raise "#{tool_name} image generation failed" unless result_code == 0

          File.binread(target_file.path)
        ensure
          target_file.unlink
        end
      end
    end
  end
end
