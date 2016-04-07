require 'tempfile'
require 'open3'

module Asciidoctor
  module Diagram
    # @private
    module CliGenerator
      def self.generate_stdin(tool, format, code)
        tool_name = File.basename(tool)

        target_file = Tempfile.new([tool_name, ".#{format}"])
        begin
          target_file.close

          opts = yield tool, target_file.path

          generate(opts, target_file, :stdin_data => code)
        ensure
          target_file.unlink
        end
      end

      def self.generate_file(tool, input_ext, output_ext, code)
        tool_name = File.basename(tool)

        source_file = Tempfile.new([tool_name, ".#{input_ext}"])
        begin
          File.write(source_file.path, code)

          target_file = Tempfile.new([tool_name, ".#{output_ext}"])
          begin
            target_file.close

            opts = yield tool, source_file.path, target_file.path

            generate(opts, target_file)
          ensure
            target_file.unlink
          end
        ensure
          source_file.unlink
        end
      end

      def self.generate(opts, target_file, open3_opts = {})
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

        run_cli(*args, open3_opts)

        if out_file
          File.rename(out_file, target_file.path)
        end

        File.binread(target_file.path)
      end

      def self.run_cli(*args)
        stdout, stderr, status = Open3.capture3(*args)

        if status != 0
          raise "#{File.basename(args[0])} failed: #{stdout.empty? ? stderr : stdout}"
        end

        stdout
      end
    end
  end
end
