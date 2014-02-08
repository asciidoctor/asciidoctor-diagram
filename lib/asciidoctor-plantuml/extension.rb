require 'open3'
require 'digest'

module Asciidoctor
  module PlantUml
    PLANTUML_JAR_PATH = File.expand_path File.join('..', 'plantuml.jar'), File.dirname(__FILE__)

    PLANTUML_PARAMS = {
        :txt => [:literal, '-tutxt', Encoding::UTF_8],
        :utxt => [:literal, '-tutxt', Encoding::UTF_8],
        :svg => [:image, '-tsvg', Encoding::ASCII_8BIT],
        :png => [:image, nil, Encoding::ASCII_8BIT]
    }

    class Block < Asciidoctor::Extensions::BlockProcessor
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def process(parent, reader, attributes)
        plantuml_lines = reader.lines * "\n"
        format = attributes.delete('format')
        target = attributes.delete('target')

        block_type, format_flag, encoding = PLANTUML_PARAMS[format.to_sym]

        result = plantuml(plantuml_lines, format_flag)
        result.force_encoding(encoding)

        case block_type
          when :image
            image_name = "#{target || file_name(plantuml_lines)}.#{format}"
            image_dir = document.attributes['imagesdir'] || ''
            File.open(File.expand_path(image_name, image_dir), "w") { |f| f.write result }

            attributes['target'] = image_name
            attributes['alt'] ||= if (title_text = attributes['title'])
              title_text
            elsif target
              (::File.basename target, (::File.extname target) || '').tr '_-', ' '
            else
              'Diagram'
            end
            Asciidoctor::Block.new parent, :image, :content_model => :empty, :attributes => attributes
          when :literal
            Asciidoctor::Block.new parent, :literal, :source => result, :attributes => attributes
          else
            raise "Unsupported block type: #{block_type}"
        end
      end

      private

      def plantuml(code, format_flag)
        java_home = ENV['JAVA_HOME'] or raise 'The JAVA_HOME environment variable should be set to a JRE or JDK installation path.'
        java_cmd = File.expand_path('bin/java', java_home)

        cmd = "#{java_cmd} -jar " + PLANTUML_JAR_PATH + " -charset UTF-8 -failonerror -pipe"
        cmd << " #{format_flag}" if format_flag

        result, status = Open3.capture2e(cmd, :stdin_data => code.encode(Encoding::UTF_8))
        raise "PlantUML exited with code #{status.exitstatus}" if status.exitstatus != 0
        result
      end

      def file_name(code)
        sha256 = Digest::SHA256.new
        sha256 << code
        sha256.hexdigest
      end
    end
  end
end
