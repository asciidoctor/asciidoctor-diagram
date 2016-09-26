require 'rbconfig'

module Asciidoctor
  module Diagram
    module Platform
      def self.os
        os_info[:os]
      end

      def self.os_variant
        os_info[:os_variant]
      end

      def self.path_separator
        os_info[:path_sep]
      end

      def self.os_info
        @os ||= (
        host_os = RbConfig::CONFIG['host_os']

        path_sep = '/'
        variant = nil
        case host_os
          when /(mswin|bccwin|wince|emc)/i
            os = :windows
            variant = $1.downcase.to_sym
            path_sep = '\\'
          when /(msys|mingw|cygwin)/i
            os = :windows
            variant = $1.downcase.to_sym
          when /darwin|mac os/i
            os = :macosx
          when /linux/i
            os = :linux
          else
            os = :unix
        end
        {
            :os => os, :os_variant => variant || os, :path_sep => path_sep
        }
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
