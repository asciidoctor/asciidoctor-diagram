require 'socket'
require_relative 'which'

module Asciidoctor
  module Diagram
    # @private
    module Java
      class CommandServer
        def initialize(classpath)
          @server = TCPServer.new 0

          args = []
          args << '-cp'
          args << classpath.flatten.join(File::PATH_SEPARATOR)
          args << 'org.asciidoctor.diagram.CommandServer'
          args << '-p'
          args << @server.addr[1].to_s

          # TODO make lookup of java executable more robust
          java_exe = ::Asciidoctor::Diagram.which('java')

          @pid = Process.spawn(java_exe, *args)

          @client = @server.accept
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
        @command_server ||= CommandServer.new(classpath)
      end

      def self.send_request(req)
        svr = command_server
        format_request(req, svr.io)
        parse_response(svr.io)
      end
    end
  end
end