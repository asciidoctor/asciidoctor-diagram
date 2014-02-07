require 'open3'
require 'digest'

module Asciidoctor
  module PlantUml
    PLANTUML_JAR_PATH = File.expand_path File.join('..', 'plantuml.jar'), File.dirname(__FILE__)

    class Block < Asciidoctor::Extensions::BlockProcessor
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def process(parent, reader, attributes)
        plantuml_lines = reader.lines
        format = attributes['format']
        image_name = "#{attributes['target'] || file_name(plantuml_lines)}.#{format}"
        result = plantuml(plantuml_lines * "\n", image_name, document.attributes['imagesdir'] || '', format)

        Asciidoctor::Block.new(parent, result[:type], :source => result[:source], :attributes => attributes)
      end

      private

      def plantuml(code, file_name, image_dir, format)
        java_home = ENV['JAVA_HOME'] or raise 'The JAVA_HOME environment variable should be set to a JRE or JDK installation path.'
        java_cmd = File.expand_path('bin/java', java_home)

        format_flag = case format
                        when 'svg'
                          ' -tsvg'
                        else
                          ''
                      end

        cmd = "#{java_cmd} -jar " + PLANTUML_JAR_PATH + " -failonerror -pipe" + format_flag

        result, status = Open3.capture2e(cmd, :stdin_data=>code)
        if status.exitstatus == 0
          result.force_encoding('ASCII-8BIT')
          File.open(File.expand_path(file_name, image_dir), "w") { |f| f.write result }
        end

        {:type => :paragraph, :source => "image:#{file_name}[]"}
      end

      def file_name(code)
        sha256 = Digest::SHA256.new
        code.each { |line| sha256 << line }
        sha256.hexdigest
      end
    end
  end
end
