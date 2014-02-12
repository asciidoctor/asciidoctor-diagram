require 'asciidoctor/extensions'
require 'digest'
require 'json'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagrams
    BLOCK_TYPES = {
        :svg => :image,
        :png => :image,
        :txt => :asciiart
    }

    IMAGE_PARAMS = {
        :svg => {
            :encoding => Encoding::UTF_8,
            :decoder => SVG
        },
        :png => {
            :encoding => Encoding::ASCII_8BIT,
            :decoder => PNG
        }
    }

    class DiagramBlock < Asciidoctor::Extensions::BlockProcessor
      option :contexts, [:listing, :literal, :open]
      option :content_model, :simple
      option :pos_attrs, ['target', 'format']
      option :default_attrs, {'format' => 'png'}

      def process(parent, reader, attributes)
        diagram_code = reader.lines.join
        format = attributes.delete('format').to_sym

        raise "#{name} does not support output format #{format}" unless allowed_formats.include?(format)

        case BLOCK_TYPES[format]
          when :image
            create_image_block(parent, diagram_code, attributes, format)
          when :asciiart
            create_ascii_art_block(parent, diagram_code, attributes)
          else
            raise "Unsupported output format: #{format}"
        end
      end

      private

      def create_image_block(parent, diagram_code, attributes, format)
        target = attributes.delete('target')

        checksum = code_checksum(diagram_code)

        image_name = "#{target || checksum}.#{format}"
        image_dir = File.expand_path(document.attributes['imagesdir'] || '', parent.document.attributes['docdir'])
        image_file = File.expand_path(image_name, image_dir)
        cache_file = File.expand_path("#{image_name}.cache", image_dir)

        if File.exists? cache_file
          metadata = File.open(cache_file, 'r') { |f| JSON.load f }
        else
          metadata = nil
        end

        unless File.exists?(image_file) && metadata && metadata['checksum'] == checksum
          params = IMAGE_PARAMS[format]

          result = generate_image(parent, diagram_code, format)

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

      def create_ascii_art_block(parent, diagram_code, attributes)
        attributes.delete('target')

        result = generate_text(parent, diagram_code)

        result.force_encoding(Encoding::UTF_8)
        Asciidoctor::Block.new parent, :literal, :source => result, :attributes => attributes
      end

      def code_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end
  end
end
