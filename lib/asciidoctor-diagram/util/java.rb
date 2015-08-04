module Asciidoctor
  module Diagram
    # @private
    module Java
      def self.classpath
        @classpath ||= [
            File.expand_path(File.join('../..', 'asciidoctor-diagram-java-1.3.4.jar'), File.dirname(__FILE__))
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
    end
  end
end

if RUBY_PLATFORM == "java"
  require_relative 'java_jruby'
else
  require_relative 'java_socket'
end
