require 'digest'
require 'json'
require_relative 'diagram'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagrams
    PLANTUML_JAR_PATH = File.expand_path File.join('..', 'plantuml.jar'), File.dirname(__FILE__)

    class PlantUmlBlock < DiagramBlock
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def name
        "PlantUml"
      end

      def allowed_formats
        @allowed_formats ||= [:svg, :png, :txt]
      end

      def generate_image(parent, diagram_code, format)
        flags = get_default_flags(parent)
        if format == :svg
          flags << "-tsvg"
        end

        plantuml(diagram_code, *flags)
      end

      def generate_text(parent, diagram_code)
        flags = get_default_flags(parent)
        flags << '-tutxt'

        plantuml(diagram_code, *flags)
      end

      private

      Java.classpath << PLANTUML_JAR_PATH

      def plantuml(code, *flags)
        code = "@startuml\n#{code}\n@enduml" unless code.index '@startuml'

        # When the -pipe command line flag is used, PlantUML calls System.exit which kills our process. In order
        # to avoid this we call some lower level components of PlantUML directly.
        # This snippet of code corresponds approximately with net.sourceforge.plantuml.Run#managePipe
        cmd = ['-charset', 'UTF-8', '-failonerror']
        cmd += flags

        option = Java.net.sourceforge.plantuml.Option.new(Java.array_to_java_array(cmd, :string))
        source_reader = Java.net.sourceforge.plantuml.SourceStringReader.new(
            Java.net.sourceforge.plantuml.preproc.Defines.new(),
            code,
            option.getConfig()
        )

        bos = Java.java.io.ByteArrayOutputStream.new
        ps = Java.java.io.PrintStream.new(bos)
        source_reader.generateImage(ps, 0, option.getFileFormatOption())
        ps.close
        Java.string_from_java_bytes(bos.toByteArray)
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

      def code_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end
  end
end
