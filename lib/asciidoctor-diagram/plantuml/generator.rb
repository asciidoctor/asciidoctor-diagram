require_relative '../util/java'

module Asciidoctor
  module Diagram
    module PlantUmlGenerator
      private

      PLANTUML_JAR_PATH = File.expand_path File.join('../..', 'plantuml.jar'), File.dirname(__FILE__)
      Java.classpath << PLANTUML_JAR_PATH

      def plantuml(parent, code, tag, *flags)
        unless @graphvizdot
          @graphvizdot = parent.document.attributes['graphvizdot']
          @graphvizdot = which('dot') unless @graphvizdot && File.executable?(@graphvizdot)
          raise "Could not find the Graphviz 'dot' executable in PATH; add it to the PATH or specify its location using the 'graphvizdot' document attribute" unless @graphvizdot
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

      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
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
