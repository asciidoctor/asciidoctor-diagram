require 'tempfile'
require 'open3'

module Asciidoctor
  module Diagram
    # @private
    module CliGenerator
      def self.generate_stdin(tool, code)
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

      def self.generate_file(tool, code)
        tool_name = File.basename(tool)

        source_file = Tempfile.new(tool_name)
        begin
          File.write(source_file.path, code)

          target_file = Tempfile.new(tool_name)
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

            run_cli(*args)

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

      def self.run_cli(*args)
        stdout, status = Open3.capture2e(*args)

        raise "#{File.basename(args[0])} failed: #{stdout}" unless status == 0

        stdout
      end
    end
  end
end
