require 'json'

module Asciidoctor
  module Diagram
    # @private
    module Java
      def self.classpath
        @classpath ||= [
            File.expand_path(File.join('../..', 'server-1.3.16.jar'), File.dirname(__FILE__))
        ]
      end

      CRLF = "\r\n".encode(Encoding::US_ASCII)

      def self.format_request(req, io)
        io.set_encoding Encoding::US_ASCII
        io.write "POST #{req[:url]} HTTP/1.1"
        io.write CRLF

        headers = req[:headers]
        if headers
          headers.each_pair do |key, value|
            io.write "#{key}: #{value}"
            io.write CRLF
          end
        end

        if req[:body]
          unless headers && headers['Content-Length']
            io.write 'Content-Length: '
            io.write req[:body].bytesize.to_s
            io.write CRLF
          end

          unless headers && headers['Content-Type']
            io.write 'Content-Type: text/plain; charset='
            io.write req[:body].encoding.name
            io.write CRLF
          end
        end

        io.write CRLF

        io.set_encoding Encoding::BINARY
        io.write req[:body]
      end

      STATUS_LINE = Regexp.new("HTTP/1.1 (\\d+) (.*)\r\n".encode(Encoding::US_ASCII))

      def self.parse_response(io)
        resp = {}

        io.set_encoding Encoding::US_ASCII
        status_line = io.readline(CRLF)
        status_line_parts = STATUS_LINE.match status_line
        unless status_line_parts
          raise "Unexpected HTTP status line: #{status_line}"
        end

        resp[:code] = status_line_parts[1].to_i
        resp[:reason] = status_line_parts[2]

        headers = {}
        until (header = io.readline(CRLF).strip).empty?
          key, value = header.split ':', 2
          headers[key] = value.strip
        end

        resp[:headers] = headers

        content_length = headers['Content-Length']
        if content_length
          io.set_encoding Encoding::BINARY
          resp[:body] = io.read(content_length.to_i)
        end

        resp
      end

      def self.create_error(prefix_msg, response)
        content_type = response[:headers]['Content-Type'] || 'text/plain'
        if content_type.start_with? 'application/json'
          json = JSON.parse(response[:body].force_encoding(Encoding::UTF_8))
          ruby_bt = Kernel.caller(2)
          java_bt = json['stk'].map { |java_line| "#{java_line[0]}:#{java_line[3]}: in '#{java_line[2]}'" }
          error = RuntimeError.new("#{prefix_msg}: #{json['msg']}")
          error.set_backtrace java_bt + ruby_bt
          raise error
        elsif content_type.start_with? 'text/plain'
          raise "#{prefix_msg}: #{response[:reason]} #{response[:body].force_encoding(Encoding::UTF_8)}"
        else
          raise "#{prefix_msg}: #{response[:reason]}"
        end
      end

      def self.java
        @java_exe ||= find_java
        raise "Could not find Java executable" unless @java_exe
        @java_exe
      end

      private
      def self.find_java
        case ::Asciidoctor::Diagram::Platform.os
          when :windows
            path_to(ENV['JAVA_HOME'], 'bin/java.exe') || registry_lookup || ::Asciidoctor::Diagram::Which.which('java')
          when :macosx
            path_to(ENV['JAVA_HOME'], 'bin/java') || path_to(::Asciidoctor::Diagram::Cli.run('/usr/libexec/java_home')[:out].strip, 'bin/java') || ::Asciidoctor::Diagram::Which.which('java')
          else
            path_to(ENV['JAVA_HOME'], 'bin/java') || ::Asciidoctor::Diagram::Which.which('java')
        end
      end

      def self.path_to(java_home, java_binary)
        exe_path = File.expand_path(java_binary, java_home)
        if File.executable?(exe_path)
          exe_path
        else
          nil
        end
      end

      JDK_KEY = 'HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit'
      JRE_KEY = 'HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment'

      def self.registry_lookup
        registry_current(JRE_KEY) || registry_current(JDK_KEY) || registry_any()
      end

      def self.registry_current(key)
        current_version = registry_query(key, 'CurrentVersion')
        if current_version
          java_home = registry_query("#{key}\\#{current_version}", 'JavaHome')
          java_exe(java_home)
        else
          nil
        end
      end

      def self.registry_any()
        java_homes = registry_query('HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft', 'JavaHome', :recursive => true).values
        java_homes.map { |path| java_exe(path) }.find { |exe| !exe.nil? }
      end

      def self.java_exe(java_home)
        java = File.expand_path('bin/java.exe', java_home)

        if File.executable?(java)
          java
        else
          nil
        end
      end

      def self.registry_query(key, value = nil, opts = {})
        args = ['reg', 'query']
        args << key
        args << '/v' << value unless value.nil?
        args << '/s' if opts[:recursive]

        begin
          lines = ::Asciidoctor::Diagram::Cli.run(*args)[:out].lines.reject { |l| l.strip.empty? }.each
        rescue
          lines = [].each
        end

        result = {}

        while true
          begin
            begin
              k = lines.next
            rescue StopIteration
              break
            end

            unless k.start_with? key
              next
            end

            v = nil
            begin
              v = lines.next.strip if lines.peek.start_with?(' ')
            rescue StopIteration
              break
            end

            if !k.valid_encoding? || (v && !v.valid_encoding?)
              next
            end

            if v && (md = /([^\s]+)\s+(REG_[^\s]+)\s+(.+)/.match(v))
              v_name = md[1]
              v_value = md[3]
              result["#{k}\\#{v_name}"] = v_value
            else
              result[k] = v
            end
          end
        end

        if value && !opts[:recursive]
          result.values[0]
        else
          result
        end
      end
    end
  end
end

if RUBY_PLATFORM == "java"
  require_relative 'java_jruby'
else
  require_relative 'java_socket'
end
