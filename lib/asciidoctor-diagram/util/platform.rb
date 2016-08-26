require 'rbconfig'

module Asciidoctor
  module Diagram
    module Platform
      def self.os
        os_info[:os]
      end

      def self.path_separator
        os_info[:path_sep]
      end

      def self.os_info
        @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
          when /mswin|bccwin|wince|emc/
            {:os => :windows, :path_sep => '\\'}
          when /msys|mingw|cygwin/
            {:os => :windows, :path_sep => '/'}
          when /darwin|mac os/
            {:os => :macosx, :path_sep => '/'}
          when /linux/
            {:os => :linux, :path_sep => '/'}
          when /solaris|bsd/
            {:os => :unix, :path_sep => '/'}
          else
            raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
        )
      end

      def self.native_path(path)
        return path if path.nil?

        path_sep = path_separator
        if path_sep != '/'
          path.to_s.gsub('/', path_sep)
        else
          path.to_s
        end
      end
    end
  end
end
