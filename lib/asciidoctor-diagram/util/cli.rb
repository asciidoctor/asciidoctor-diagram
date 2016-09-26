require 'tempfile'
require 'open3'

module Asciidoctor
  module Diagram
    # @private
    module Cli
      def self.run(*args)
        stdout, stderr, status = Open3.capture3(*args)

        if status != 0
          raise "#{File.basename(args[0])} failed: #{stdout.empty? ? stderr : stdout}"
        end

        stdout.empty? ? stderr : stdout
      end
    end
  end
end
