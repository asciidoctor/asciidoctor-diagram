require_relative '../util/diagram'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    module DitaaGenerator
      DITAA_JAR_PATH = File.expand_path File.join('../..', 'ditaamini0_9.jar'), File.dirname(__FILE__)
      Java.classpath << DITAA_JAR_PATH

      def self.ditaa(code)
        Java.load

        args = ['-e', 'UTF-8']

        bytes = code.encode(Encoding::UTF_8).bytes.to_a
        bis = Java.new_object(Java.java.io.ByteArrayInputStream, '[B', Java.array_to_java_array(bytes, :byte))
        bos = Java.new_object(Java.java.io.ByteArrayOutputStream)
        result_code = Java.org.stathissideris.ascii2image.core.CommandLineConverter.convert(Java.array_to_java_array(args, :string), bis, bos)
        bis.close
        bos.close

        result = Java.string_from_java_bytes(bos.toByteArray)

        raise "Ditaa image generation failed: #{result}" unless result_code == 0

        result
      end
    end

    define_processors('Ditaa') do
      register_format(:png, :image) do |c|
        DitaaGenerator.ditaa(c)
      end
    end
  end
end