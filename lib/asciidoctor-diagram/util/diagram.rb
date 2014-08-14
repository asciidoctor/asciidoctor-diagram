require 'asciidoctor/extensions'
require 'digest'
require 'json'
require 'fileutils'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagram
    def self.define_processors(name, &init)
      block = Class.new(Asciidoctor::Extensions::BlockProcessor) do
        class << self
          include FormatRegistry
        end
        include DiagramProcessor

        option :pos_attrs, ['target', 'format']
        option :contexts, [:listing, :literal, :open]
        option :content_model, :simple

        def process(parent, reader, attributes)
          generate_block(parent, ReaderSource.new(reader), attributes)
        end

        self.instance_eval &init
      end

      block_macro = Class.new(Asciidoctor::Extensions::BlockMacroProcessor) do
        class << self
          include FormatRegistry
        end
        include DiagramProcessor

        option :pos_attrs, ['target', 'format']

        def process(parent, target, attributes)
          source = FileSource.new(File.expand_path(target, parent.document.attributes['docdir']))
          attributes['target'] ||= File.basename(target, File.extname(target))

          generate_block(parent, source, attributes)
        end

        self.instance_eval &init
      end

      Asciidoctor::Diagram.const_set("#{name}Block", block)
      Asciidoctor::Diagram.const_set("#{name}BlockMacro", block_macro)
    end

    module FormatRegistry
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

      def default_format
        @default_format
      end
    end

    module DiagramProcessor
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

      private

      def generate_block(parent, source, attributes)
        format = attributes.delete('format') || self.class.default_format
        format = format.to_sym if format.respond_to?(:to_sym)

        raise "Format undefined" unless format

        generator_info = self.class.formats[format]

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

      def create_image_block(parent, source, attributes, format, generator_info)
        target = attributes.delete('target')

        image_name = "#{target || ('diag-' + source.checksum)}.#{format}"
        image_dir = File.expand_path(parent.document.attributes['imagesdir'] || '', parent.document.attributes['outdir'] || parent.document.attributes['docdir'])
        image_file = File.expand_path(image_name, image_dir)
        metadata_file = File.expand_path("#{image_name}.cache", image_dir)

        if File.exists? metadata_file
          metadata = File.open(metadata_file, 'r') { |f| JSON.load f }
        else
          metadata = {}
        end

        if source.should_process?(image_file, metadata['checksum'])
          params = IMAGE_PARAMS[format]

          result = generator_info[:generator].call(source.code, parent)

          result.force_encoding(params[:encoding])

          metadata = {'checksum' => source.checksum}
          metadata['width'], metadata['height'] = params[:decoder].get_image_size(result)

          FileUtils.mkdir_p(image_dir) unless Dir.exists?(image_dir)
          File.open(image_file, 'wb') { |f| f.write result }
          File.open(metadata_file, 'w') { |f| JSON.dump(metadata, f) }
        end

        attributes['target'] = image_name
        if /html/i =~ parent.document.attributes['backend']
          attributes['width'] ||= metadata['width'] if metadata['width']
          attributes['height'] ||= metadata['height'] if metadata['height']
        end
        attributes['alt'] ||= if title_text = attributes['title']
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
      def checksum
        @checksum ||= compute_checksum(code)
      end

      def should_process?(image_file, old_checksum)
        !File.exists?(image_file) || (newer_than?(image_file) && old_checksum != checksum)
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

      def newer_than?(image_file)
        true
      end

      def code
        @code ||= @reader.lines.join("\n")
      end
    end

    class FileSource < Source
      def initialize(file_name)
        @file_name = file_name
      end

      def newer_than?(image_file)
        File.mtime(@file_name) > File.mtime(image_file)
      end

      def code
        @code ||= File.read(@file_name)
      end
    end
  end
end
