require 'asciidoctor/extensions'
require 'digest'
require 'json'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagram
    module DiagramBlockProcessor
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

      def self.included(base)
        base.option :contexts, [:listing, :literal, :open]
        base.option :content_model, :simple
        base.option :pos_attrs, ['target', 'format']
      end

      def process(parent, reader, attributes)
        diagram_code = reader.lines.join
        format = attributes.delete('format') || @default_format
        format = format.to_sym if format.respond_to?(:to_sym)

        raise "Format undefined" unless format

        generator_info = formats[format]

        raise "#{self.class.name} does not support output format #{format}" unless generator_info

        case generator_info[:type]
          when :image
            create_image_block(parent, diagram_code, attributes, format, generator_info)
          when :literal
            create_literal_block(parent, diagram_code, attributes, format, generator_info)
          else
            raise "Unsupported output format: #{format}"
        end
      end

      private

      #
      # Registers a supported format. The first registered format becomes the default format for the block processor.
      #
      # +format+ is a symbol with the format name
      # +type+ is a symbol and should be either :image or :literal
      # +generator+ is a symbol with the name of a generator function which should accept arguments (parent, code, ...)
      # +args+ is an array of arguments that will be passed to the generator splatted after the fixed arguments
      #
      def register_format(format, type, generator, args)
        unless @default_format
          @default_format = format
        end

        formats[format] = {
            :type => type,
            :generator => generator,
            :args => args
        }
      end

      def formats
        @formats ||= {}
      end

      def create_image_block(parent, diagram_code, attributes, format, generator_info)
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

          result = send(generator_info[:generator], parent, diagram_code, *(generator_info[:args] || []))

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

      def create_literal_block(parent, diagram_code, attributes, format, generator_info)
        attributes.delete('target')

        result = send(generator_info[:generator], parent, diagram_code, *(generator_info[:args] || []))

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
