module Asciidoctor
  module Diagram
    # @private
    module Cli
      if RUBY_PLATFORM == "java"
        # Workaround for https://github.com/jruby/jruby/issues/5565
        #   Kernel.spawn (and as a consequence Open3.capture3 which uses it)
        #   is not reliable on all versions of JRuby.
        require_relative 'java'

        def self.run(*args)
          opts = args.pop.dup if args.last.is_a? Hash
          in_data = opts && opts[:stdin_data]

          if Hash === args.first
            env = args.shift.dup
          else
            env = {}
          end

          pb = java.lang.ProcessBuilder.new(*args)
          env.each_pair do |key, value|
            pb.environment.put(key, value)
          end
          p = pb.start

          stdout = ""
          out_reader = start_stream_reader(p.getInputStream, stdout)
          stderr = ""
          err_reader = start_stream_reader(p.getErrorStream, stderr)

          if in_data
            p.getOutputStream.write(in_data.to_java_bytes)
            p.getOutputStream.close
          end

          p.waitFor

          out_reader.join
          err_reader.join

          status = p.exitValue

          if status != 0
            raise "#{File.basename(args[0])} failed: #{stdout.empty? ? stderr : stdout}"
          end

          {
              :out => stdout,
              :err => stderr,
              :status => status
          }
        end

        private
        def self.start_stream_reader(in_stream, out_string)
          Thread.new {
            buffer = ::Java::byte[4096].new
            while (bytes_read = in_stream.read(buffer)) != -1
              if bytes_read < buffer.length
                str = String.from_java_bytes(java.util.Arrays.copyOf(buffer, bytes_read))
              else
                str = String.from_java_bytes(buffer)
              end
              out_string << str
            end
          }
        end
      else
        require 'open3'

        def self.run(*args)
          if Hash === args.last
            opts = args.pop.dup
          else
            opts = {}
          end

          if Hash === args.first
            env = args.shift.dup
          else
            env = {}
          end

          # When the first argument is an array, we force capture3 (or better the underlying Kernel#spawn)
          # to use a non-shell execution variant.
          cmd = File.basename(args[0])
          args[0] = [args[0], cmd]

          stdout, stderr, status = Open3.capture3(env, *args, opts)

          exit = status.exitstatus

          if exit != 0
            raise "#{cmd} failed: #{stdout.empty? ? stderr : stdout}"
          end

          {
              :out => stdout,
              :err => stderr,
              :status => exit
          }
        end
      end
    end
  end
end
