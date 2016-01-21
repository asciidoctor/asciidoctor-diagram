require 'tempfile'

module Asciidoctor
  module Diagram
    # @private
    module CliGenerator
      def self.generate_stdin(tool, format, code)
        tool_name = File.basename(tool)

        target_file = Tempfile.new([tool_name, ".#{format}"])
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

      def self.generate_file(tool, format, code)
        tool_name = File.basename(tool)

        source_file = Tempfile.new([tool_name, ".#{format}"])
        begin
          File.write(source_file.path, code)

          target_file = Tempfile.new([tool_name, ".#{format}"])
          begin
            target_file.close

            opts = yield tool, source_file.path, target_file.path

            case opts
              when Array
                args = opts
                out_file = nil
              when Hash
                args = opts[:args]
                out_file = opts[:out_file]
              else
                raise "Block passed to generate_file should return an Array or a Hash"
            end

            system(*args)

            result_code = $?

            raise "#{tool_name} image generation failed" unless result_code == 0

            if out_file
              File.rename(out_file, target_file.path)
            end

            File.binread(target_file.path)
          ensure
            target_file.unlink
          end
        ensure
          source_file.unlink
        end
      end
    end
  end
end
