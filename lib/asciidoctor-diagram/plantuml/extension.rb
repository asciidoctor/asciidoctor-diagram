require_relative '../extensions'

module Asciidoctor
  module Diagram
    # @private
    module PlantUml
      private

      PLANTUML_JAR_PATH = File.expand_path File.join('../..', 'plantuml.jar'), File.dirname(__FILE__)
      Java.classpath << PLANTUML_JAR_PATH

      def plantuml(parent, code, tag, *flags)
        unless @graphvizdot
          @graphvizdot = parent.document.attributes['dot']
          @graphvizdot = ::Asciidoctor::Diagram.which('dot') unless @graphvizdot && File.executable?(@graphvizdot)
          raise "Could not find the Graphviz 'dot' executable in PATH; add it to the PATH or specify its location using the 'dot' document attribute" unless @graphvizdot
        end

        Java.load

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index "@start#{tag}"

        flags += ['-charset', 'UTF-8', '-failonerror', '-graphvizdot', @graphvizdot]

        config_file = parent.document.attributes['plantumlconfig']
        if config_file
          flags += ['-config', File.expand_path(config_file, parent.document.attributes['docdir'])]
        end

        option = Java.new_object( Java.net.sourceforge.plantuml.Option, '[Ljava.lang.String;', Java.array_to_java_array(flags, :string) )
        source_reader = Java.new_object( Java.net.sourceforge.plantuml.SourceStringReader,
                                         'Lnet.sourceforge.plantuml.preproc.Defines;Ljava.lang.String;Ljava.util.List;',
                                         Java.new_object( Java.net.sourceforge.plantuml.preproc.Defines ),
                                         code,
                                         option.getConfig()
        )

        bos = Java.new_object( Java.java.io.ByteArrayOutputStream )
        ps = Java.new_object( Java.java.io.PrintStream, 'Ljava.io.OutputStream;', bos )
        source_reader.generateImage(ps, 0, option.getFileFormatOption())
        ps.close
        Java.string_from_java_bytes(bos.toByteArray)
      end

      def config_args(parent)
        config_args = []
        config = parent.document.attributes['plantumlconfig']
        if config
          config_args += ['-config', File.expand_path(config, parent.document.attributes['docdir'])]
        end

        config_args
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |c, p|
          plantuml(p, c.to_s, 'uml', *config_args(p))
        end
        mod.register_format(:svg, :image) do |c, p|
          plantuml(p, c.to_s, 'uml', '-tsvg', *config_args(p))
        end
        mod.register_format(:txt, :literal) do |c, p|
          plantuml(p, c.to_s, 'uml', '-tutxt', *config_args(p))
        end
      end
    end

    class PlantUmlBlockProcessor < Extensions::DiagramBlockProcessor
      include PlantUml
    end

    class PlantUmlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include PlantUml
    end
  end
end
