require 'asciidoctor/extensions'
require 'digest'
require 'json'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagram
    module DiagramProcessorBase
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
        base.option :pos_attrs, ['target', 'format']

        if base.ancestors.include?(Asciidoctor::Extensions::BlockProcessor)
          base.option :contexts, [:listing, :literal, :open]
          base.option :content_model, :simple

          base.instance_eval do
            alias_method :process, :process_block
          end
        else
          base.instance_eval do
            alias_method :process, :process_macro
          end
        end

      end

      def process_macro(parent, target, attributes)
        source = FileSource.new(target)
        attributes['target'] = File.basename(target, File.extname(target))

        generate_block(parent, source, attributes)
      end

      def process_block(parent, reader, attributes)
        generate_block(parent, ReaderSource.new(reader), attributes)
      end

      def generate_block(parent, source, attributes)
        format = attributes.delete('format') || @default_format
        format = format.to_sym if format.respond_to?(:to_sym)

        raise "Format undefined" unless format

        generator_info = formats[format]

        raise "#{self.class.name} does not support output format #{format}" unless generator_info

        case generator_info[:type]
          when :image
            create_image_block(parent, source, attributes, format, generator_info)
          when :literal
            create_literal_block(parent, source, attributes, generator_info)
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
      # +block+ is a block that produces the diagrams from code. The block receives the parent asciidoc block and the diagram code as arguments
      #
      def register_format(format, type, &block)
        unless @default_format
          @default_format = format
        end

        formats[format] = {
            :type => type,
            :generator => block
        }
      end

      def formats
        @formats ||= {}
      end

      def create_image_block(parent, source, attributes, format, generator_info)
        target = attributes.delete('target')

        image_name = "#{target || source.checksum}.#{format}"
        image_dir = File.expand_path(parent.document.attributes['imagesdir'] || '', parent.document.attributes['docdir'])
        image_file = File.expand_path(image_name, image_dir)

        if source.newer_than?(image_file)
          cache_file = File.expand_path("#{image_name}.cache", image_dir)

          if File.exists? cache_file
            metadata = File.open(cache_file, 'r') { |f| JSON.load f }
          else
            metadata = nil
          end

          unless File.exists?(image_file) && metadata && metadata['checksum'] == source.checksum
            params = IMAGE_PARAMS[format]

            result = generator_info[:generator].call(source.code, parent)

            result.force_encoding(params[:encoding])

            metadata = {'checksum' => source.checksum}
            metadata['width'], metadata['height'] = params[:decoder].get_image_size(result)

            File.open(image_file, 'w') { |f| f.write result }
            File.open(cache_file, 'w') { |f| JSON.dump(metadata, f) }
          end
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

      def create_literal_block(parent, source, attributes, generator_info)
        attributes.delete('target')

        result = generator_info[:generator].call(source.code, parent)

        result.force_encoding(Encoding::UTF_8)
        Asciidoctor::Block.new parent, :literal, :code => result, :attributes => attributes
      end

      def code_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end

    class Source
      def newer_than?(image)
        true
      end

      def checksum
        @checksum ||= compute_checksum(code)
      end

      private

      def compute_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end

    class ReaderSource < Source
      def initialize(reader)
        @reader = reader
      end

      def code
        @code ||= @reader.lines.join
      end
    end

    class FileSource < Source
      def initialize(file_name)
        @file_name = file_name
      end

      def code
        @code ||= File.read(@file_name)
      end

      def newer_than?(image)
        !File.exists?(image) || File.mtime(@file_name) > File.mtime(image)
      end
    end
  end
end
