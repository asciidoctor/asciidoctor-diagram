require_relative '../diagram'
require_relative '../java'
require_relative '../png'
require_relative '../svg'

module Asciidoctor
  module Diagram
    DITAA_JAR_PATH = File.expand_path File.join('../..', 'ditaamini0_9.jar'), File.dirname(__FILE__)

    class DitaaBlock < DiagramBlock
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def name
        "Ditaa"
      end

      def allowed_formats
        @allowed_formats ||= [:png]
      end

      def generate_image(parent, diagram_code, format)
        ditaa(diagram_code)
      end

      private

      Java.classpath << DITAA_JAR_PATH

      def ditaa(code, *flags)
        Java.load

        cmd = ['-e', 'UTF-8']
        cmd += flags if flags

        bytes = code.encode(Encoding::UTF_8).bytes.to_a
        bis = Java.java.io.ByteArrayInputStream.new(Java.array_to_java_array(bytes, :byte))
        bos = Java.java.io.ByteArrayOutputStream.new
        result_code = Java.org.stathissideris.ascii2image.core.CommandLineConverter.convert(Java.array_to_java_array(cmd, :string), bis, bos)
        bis.close
        bos.close

        result = Java.string_from_java_bytes(bos.toByteArray)

        raise "Ditaa image generation failed: #{result}" unless result_code == 0

        result
      end

      def get_default_flags(parent)
        flags = []

        document = parent.document
        config = document.attributes['plantumlconfig']
        if config
          flags += ['-config', File.expand_path(config, document.attributes['docdir'])]
        end

        flags
      end
    end
  end
end