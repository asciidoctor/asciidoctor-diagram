require 'tempfile'

require_relative '../util/java'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    module ShaapeGenerator
      private

      def shaape(code)
        unless @shaape
          @shaape = parent.document.attributes['shaape']
          @shaape = ::Asciidoctor::Diagram.which('shaape') unless @shaape && File.executable?(@shaape)
          raise "Could not find the Shaape 'shaape' executable in PATH; add it to the PATH or specify its location using the 'shaape' document attribute" unless @shaape
        end

        target_file = Tempfile.new('shaape')
        begin
          target_file.close

          args = [@shaape, '-o', target_file.path, '-']
          Kernel.system(*args, :in => StringIO.new(code, "r"))
          result_code = $?

          raise "Shaape image generation failed" unless result_code == 0

          File.read(target_file.path)
        ensure
          target_file.unlink
        end
      end
    end
  end
end
