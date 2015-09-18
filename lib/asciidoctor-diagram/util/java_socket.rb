require 'socket'
require 'rbconfig'

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
          # special case for cygwin, it requires path translation for java to work
          if RbConfig::CONFIG['host_os'] =~ /cygwin/i
            cygpath = ::Asciidoctor::Diagram.which('cygpath')
            if(cygpath != nil) 
              args << classpath.flatten.map { |jar| `cygpath -w "#{jar}"`.strip }.join(";")
            else
              puts 'cygwin warning: cygpath not found'
              args << classpath.flatten.join(File::PATH_SEPARATOR)
            end
          else
            args << classpath.flatten.join(File::PATH_SEPARATOR)
          end
          args << 'org.asciidoctor.diagram.CommandServer'

          @server = IO.popen([java, *args])
          @port = @server.readline.strip.to_i
          @client = TCPSocket.new 'localhost', port
        end

        def io
          @client
        end

        def shutdown
          # KILL is a bit heavy handed, but TERM does not seem to shut down the JVM on Windows.
          Process.kill('KILL', @server.pid)
        end
      end

      def self.load
        if @loaded
          return
        end

        instance
        @loaded = true
      end

      def self.instance
        @java_exe ||= find_java
        raise "Could not find Java executable" unless @java_exe

        unless @command_server
          server = CommandServer.new(@java_exe, classpath)
          @command_server = server
          at_exit do
            server.shutdown
          end
        end

        @command_server
      end

      def self.send_request(req)
        svr = instance
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