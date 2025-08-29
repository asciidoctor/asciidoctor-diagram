require 'java'
require 'stringio'

module Asciidoctor
  module Diagram
    # @private
    module Java
      def self.environment_variable(key)
        ENV[key] || ENV_JAVA[key.downcase.gsub('_', '.')]
      end

      def self.load
        if defined?(@loaded) && @loaded
          return
        end

        classpath.flatten.each do |j|
          raise "Classpath item #{j} does not exist" unless File.exist?(j)
          require j
        end

        # Strange issue seen with JRuby where 'java.class.path' has the value ':'.
        # This causes issue in PlantUML which splits the class path string and then
        # raises errors when trying to handle empty strings.
        java_cp = ::Java.java.lang.System.getProperty("java.class.path")
        new_java_cp = java_cp.split(File::PATH_SEPARATOR)
                             .reject { |p| p.empty? }
                             .join(File::PATH_SEPARATOR)
        ::Java.java.lang.System.setProperty("java.class.path", new_java_cp)

        @loaded = true
      end

      def self.send_request(req)
        cp = ::Java.org.asciidoctor.diagram.CommandProcessor.new()

        req_io = StringIO.new
        format_request(req, req_io)
        req_io.close

        response = cp.processRequest(req_io.string.to_java_bytes)

        resp_io = StringIO.new(String.from_java_bytes(response))
        resp = parse_response(resp_io)
        resp_io.close

        resp
      end
    end
  end
end