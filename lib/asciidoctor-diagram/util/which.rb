module Asciidoctor
  module Diagram
    module Which
      # @private
      def self.which(cmd, options = {})
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

        paths = (options[:path] || []) + (ENV['PATH'] ? ENV['PATH'].split(File::PATH_SEPARATOR) : [])
        paths.each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          }
        end

        nil
      end
    end
  end
end
