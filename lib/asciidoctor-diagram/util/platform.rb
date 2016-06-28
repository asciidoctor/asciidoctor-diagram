require 'rbconfig'

module Asciidoctor
  module Diagram
    module Platform
      def self.os
        @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
          when /darwin|mac os/
            :macosx
          when /linux/
            :linux
          when /solaris|bsd/
            :unix
          else
            raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
        )
      end

      def self.native_path(path)
        return path if path.nil?

        case os
          when :windows
            path.to_s.gsub('/', '\\')
          else
            path.to_s
        end
      end
    end
  end
end
