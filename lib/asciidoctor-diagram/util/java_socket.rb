require 'socket'

require_relative 'cli'
require_relative 'platform'
require_relative 'which'

module Asciidoctor
  module Diagram
    # @private
    module Java
      class CommandServer
        def initialize(java, classpath)
          classpath.each do |file|
            raise "Classpath item #{file} does not exist" unless File.exist?(file)
          end

          args = []
          args << '-Djava.awt.headless=true'
          args << '-Djava.net.useSystemProxies=true'
          args << '-cp'
          args << classpath.flatten.map { |jar| ::Asciidoctor::Diagram::Platform.host_os_path(jar).strip }.join(::Asciidoctor::Diagram::Platform.host_os_path_separator)
          args << 'org.asciidoctor.diagram.StdInOutCommandServer'

          @server = IO.popen([java, *args], 'r+b')
        end

        def io
          @server
        end

        def shutdown
          # KILL is a bit heavy handed, but TERM does not seem to shut down the JVM on Windows.
          Process.kill('KILL', @server.pid)
          @server.close
        end
      end

      def self.load
        if defined?(@loaded) && @loaded
          return
        end

        instance
        @loaded = true
      end

      def self.instance
        unless defined?(@command_server) && @command_server
          server = CommandServer.new(java, classpath)
          @command_server = server
          at_exit do
            server.shutdown
          end
        end

        @command_server
      end

      def self.send_request(req)
        svr = instance
        req[:headers] ||= {}
        # headers = req[:headers] ||= {}
        # headers['Host'] = "localhost:#{svr.port}"
        format_request(req, svr.io)
        begin
          parse_response(svr.io)
        rescue
          raise "Error processing request #{req}\nEncoding of input is #{req[:body].encoding}"
        end
      end
    end
  end
end