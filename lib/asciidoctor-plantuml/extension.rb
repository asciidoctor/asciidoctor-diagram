require 'digest'
require 'json'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module PlantUml
    PLANTUML_JAR_PATH = File.expand_path File.join('..', 'plantuml.jar'), File.dirname(__FILE__)
    BLOCK_TYPES = {
        :svg => :image,
        :png => :image,
        :txt => :asciiart,
        :utxt => :asciiart,
    }

    IMAGE_PARAMS = {
        :svg => {
            :encoding => Encoding::UTF_8,
            :decoder => SVG,
            :flags => ['-tsvg']
        },
        :png => {
            :encoding => Encoding::ASCII_8BIT,
            :decoder => PNG,
            :flags => []
        }
    }

    class Block < Asciidoctor::Extensions::BlockProcessor
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def process(parent, reader, attributes)
        plantuml_code = reader.lines * "\n"
        format = attributes.delete('format').to_sym

        case BLOCK_TYPES[format]
          when :image
            create_image_block(parent, plantuml_code, attributes, format)
          when :asciiart
            create_ascii_art_block(parent, plantuml_code, attributes)
          else
            raise "Unsupported output format: #{format}"
        end
      end

      private

      def create_image_block(parent, plantuml_code, attributes, format)
        target = attributes.delete('target')

        checksum = code_checksum(plantuml_code)

        image_name = "#{target || checksum}.#{format}"
        image_dir = document.attributes['imagesdir'] || ''
        image_file = File.expand_path(image_name, image_dir)
        cache_file = File.expand_path("#{image_name}.cache", image_dir)

        if File.exists? cache_file
          metadata = File.open(cache_file, 'r') { |f| JSON.load f }
        else
          metadata = nil
        end

        unless File.exists?(image_file) && metadata && metadata['checksum'] == checksum

          params = IMAGE_PARAMS[format]

          result = plantuml(plantuml_code, *params[:flags])
          result.force_encoding(params[:encoding])

          metadata = {'checksum' => checksum}
          metadata['width'], metadata['height'] = params[:decoder].get_image_size(result)

          File.open(image_file, 'w') { |f| f.write result }
          File.open(cache_file, 'w') { |f| JSON.dump(metadata, f) }
        end

        attributes['target'] = image_name
        attributes['width'] ||= metadata['width'] if metadata['width']
        attributes['height'] ||= metadata['height'] if metadata['height']
        attributes['alt'] ||= if (title_text = attributes['title'])
                                title_text
                              elsif target
                                (File.basename target, (File.extname target) || '').tr '_-', ' '
                              else
                                'Diagram'
                              end

        Asciidoctor::Block.new parent, :image, :content_model => :empty, :attributes => attributes
      end

      def create_ascii_art_block(parent, plantuml_code, attributes)
        attributes.delete('target')

        result = plantuml(plantuml_code, '-tutxt')
        result.force_encoding(Encoding::UTF_8)
        Asciidoctor::Block.new parent, :literal, :source => result, :attributes => attributes
      end

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

      def code_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end
  end
end
