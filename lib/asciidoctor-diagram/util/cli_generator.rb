require 'asciidoctor/logging'
require 'tempfile'
require_relative 'cli'

module Asciidoctor
  module Diagram
    # @private
    module CliGenerator
      include Asciidoctor::Logging

      def generate_stdin(tool, format, code)
        target_file = Tempfile.new([File.basename(tool), ".#{format}"])
        begin
          target_file.close
          generate_stdin_file(tool, code, target_file.path) do |t|
            yield t, target_file.path
          end
        ensure
          target_file.unlink
        end
      end

      def generate_stdin_file(tool, code, target_file_path)
        opts = yield tool
        generate(opts, target_file_path, :stdin_data => code)
      end

      def generate_stdin_stdout(tool, code)
        if block_given?
          opts = yield tool
        else
          opts = [tool]
        end
        generate(opts, :stdout, :stdin_data => code, :binmode => true)
      end

      def generate_file(tool, input_ext, output_ext, code)
        tool_name = File.basename(tool)

        source_file = Tempfile.new([tool_name, ".#{input_ext}"])
        begin
          File.write(source_file.path, code)

          target_file = Tempfile.new([tool_name, ".#{output_ext}"])
          begin
            target_file.close

            opts = yield tool, source_file.path, target_file.path

            generate(opts, target_file.path)
          ensure
            target_file.unlink
          end
        ensure
          source_file.unlink
        end
      end

      def generate_file_stdout(tool, input_ext, code)
        tool_name = File.basename(tool)

        source_file = Tempfile.new([tool_name, ".#{input_ext}"])
        begin
          File.write(source_file.path, code)

          opts = yield tool, source_file.path
          generate(opts, :stdout)
        ensure
          source_file.unlink
        end
      end

      private
      def generate(opts, target_file, open3_opts = {})
        case opts
          when Array
            args = opts
            out_file = nil
            env = {}
          when Hash
            args = opts[:args]
            out_file = opts[:out_file]
            env = opts[:env] || {}
          else
            raise "Block passed to generate_file should return an Array or a Hash"
        end

        logger.debug "Executing #{args} with options #{open3_opts} and environment #{env}"
        result = ::Asciidoctor::Diagram::Cli.run(env, *args, open3_opts)

        data = target_file == :stdout ? result[:out] : read_result(target_file, out_file)

        if data.empty?
          raise "#{args[0]} failed: #{result[:out].empty? ? result[:err] : result[:out]}"
        end

        data
      end

      def read_result(target_file, out_file = nil)
        if File.exist?(out_file || target_file)
          if out_file
            File.rename(out_file, target_file)
          end

          File.binread(target_file)
        else
          ''
        end
      end
    end
  end
end
