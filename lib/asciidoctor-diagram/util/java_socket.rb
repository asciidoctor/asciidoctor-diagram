require 'socket'

require_relative 'which'

module Asciidoctor
  module Diagram
    # @private
    module Java
      class CommandServer
        attr_reader :port

        def initialize(java, classpath)
          args = []
          args << '-Djava.awt.headless=true'
          args << '-cp'
          args << classpath.flatten.join(File::PATH_SEPARATOR)
          args << 'org.asciidoctor.diagram.CommandServer'

          @server = IO.popen([java, *args])
          @port = @server.readline.strip.to_i
          @client = TCPSocket.new 'localhost', port
        end

        def io
          @client
        end
      end

      def self.load
        if @loaded
          return
        end

        command_server
        @loaded = true
      end

      def self.command_server
        @java_exe ||= find_java
        raise "Could not find Java executable" unless @java_exe
        @command_server ||= CommandServer.new(@java_exe, classpath)
      end

      def self.send_request(req)
        svr = command_server
        headers = req[:headers] ||= {}
        headers['Host'] = "localhost:#{svr.port}"
        format_request(req, svr.io)
        parse_response(svr.io)
      end

      private
      def self.find_java
        if /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
          # Windows
          path_to(ENV['JAVA_HOME'], 'bin/java.exe') || registry_lookup || ::Asciidoctor::Diagram.which('java')
        elsif /darwin/ =~ RUBY_PLATFORM
          # Mac
          path_to(ENV['JAVA_HOME'], 'bin/java') || path_to(`/usr/libexec/java_home`.strip, 'bin/java') || ::Asciidoctor::Diagram.which('java')
        else
          # Other unix-like system
          path_to(ENV['JAVA_HOME'], 'bin/java') || ::Asciidoctor::Diagram.which('java')
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

      def self.registry_lookup
        key_re = /^HKEY_LOCAL_MACHINE\\SOFTWARE\\JavaSoft\\.*\\([0-9\.]+)/
        value_re = /\s*JavaHome\s*REG_SZ\s*(.*)/
        result = `reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\JavaSoft" /s /v JavaHome`.lines.map { |l| l.strip }
        vms = result.each_slice(3).map do |_, key, value|
          key_match = key_re.match(key)
          value_match = value_re.match(value)
          if key_match && value_match
            [key_match[1].split('.').map { |v| v.to_i }, value_match[1]]
          else
            nil
          end
        end.reject { |v| v.nil? }.sort_by { |v| v[0] }
        java_exes = vms.map { |version, path| File.expand_path('bin/java.exe', path) }.select { |exe| File.executable?(exe) }
        java_exes && java_exes[0]
      end
    end
  end
end