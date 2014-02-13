require_relative '../util/java'

module Asciidoctor
  module Diagram
    module DitaaGenerator
      private

      DITAA_JAR_PATH = File.expand_path File.join('../..', 'ditaamini0_9.jar'), File.dirname(__FILE__)
      Java.classpath << DITAA_JAR_PATH

      def ditaa(parent, code, *args)
        Java.load

        args += ['-e', 'UTF-8']

        bytes = code.encode(Encoding::UTF_8).bytes.to_a
        bis = Java.java.io.ByteArrayInputStream.new(Java.array_to_java_array(bytes, :byte))
        bos = Java.java.io.ByteArrayOutputStream.new
        result_code = Java.org.stathissideris.ascii2image.core.CommandLineConverter.convert(Java.array_to_java_array(args, :string), bis, bos)
        bis.close
        bos.close

        result = Java.string_from_java_bytes(bos.toByteArray)

        raise "Ditaa image generation failed: #{result}" unless result_code == 0

        result
      end
    end
  end
end
