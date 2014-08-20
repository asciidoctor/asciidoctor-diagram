require 'asciidoctor/extensions'
require 'digest'
require 'json'
require 'fileutils'
require_relative 'java'
require_relative 'png'
require_relative 'svg'

module Asciidoctor
  module Diagram
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

      def process(parent, reader_or_target, attributes)
        source = create_source(parent, reader_or_target, attributes)

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

      def create_source(parent, reader_or_target, attributes)
        raise NotImplementedError.new
      end

      def create_image_block(parent, source, attributes, format, generator_info)
        image_name = "#{source.image_name}.#{format}"
        outdir = parent.document.attr('imagesoutdir') || parent.document.attr('outdir')
        image_dir = parent.normalize_system_path parent.document.attr 'imagesdir', outdir
        image_file = parent.normalize_system_path image_name, image_dir
        metadata_file = parent.normalize_system_path "#{image_name}.cache", image_dir

        if File.exists? metadata_file
          metadata = File.open(metadata_file, 'r') { |f| JSON.load f }
        else
          metadata = {}
        end

        if !File.exists?(image_file) || source.should_process?(image_file, metadata)
          params = IMAGE_PARAMS[format]

          result = instance_exec(source.code, parent, &generator_info[:generator])

          result.force_encoding(params[:encoding])

          metadata = source.create_image_metadata
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
                              elsif target = attributes['target']
                                (File.basename target, (File.extname target) || '').tr '_-', ' '
                              else
                                'Diagram'
                              end

        Asciidoctor::Block.new parent, :image, :content_model => :empty, :attributes => attributes
      end

      def create_literal_block(parent, source, attributes, generator_info)
        attributes.delete('target')

        result = instance_exec(source.code, parent, &generator_info[:generator])

        result.force_encoding(Encoding::UTF_8)
        Asciidoctor::Block.new parent, :literal, :source => result, :attributes => attributes
      end
    end

    class DiagramBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessor

      def self.inherited(subclass)
        class << subclass
          include FormatRegistry
        end

        subclass.option :pos_attrs, ['target', 'format']
        subclass.option :contexts, [:listing, :literal, :open]
        subclass.option :content_model, :simple
      end

      def create_source(parent, reader, attributes)
        ReaderSource.new(reader, attributes)
      end
    end

    class DiagramBlockMacroProcessor < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessor

      def self.inherited(subclass)
        class << subclass
          include FormatRegistry
        end

        subclass.option :pos_attrs, ['target', 'format']
      end

      def create_source(parent, target, attributes)
        FileSource.new(File.expand_path(target, parent.document.attributes['docdir']), attributes)
      end
    end

    module DiagramSource
      def image_name
        raise NotImplementedError.new
      end

      def code
        raise NotImplementedError.new
      end

      def should_process?(image_file, image_metadata)
        raise NotImplementedError.new
      end

      def create_image_metadata
        raise NotImplementedError.new
      end
    end

    class BasicSource
      include DiagramSource

      def initialize(attributes)
        @attributes = attributes
      end

      def image_name
        @attributes['target'] || ('diag-' + checksum)
      end

      def should_process?(image_file, image_metadata)
        image_metadata['checksum'] != checksum
      end

      def create_image_metadata
        {'checksum' => checksum}
      end

      def checksum
        @checksum ||= compute_checksum(code)
      end

      def compute_checksum(code)
        md5 = Digest::MD5.new
        md5 << code
        md5.hexdigest
      end
    end

    class ReaderSource < BasicSource
      include DiagramSource

      def initialize(reader, attributes)
        super(attributes)
        @reader = reader
      end

      def code
        @code ||= @reader.lines.join("\n")
      end
    end

    class FileSource < BasicSource
      def initialize(file_name, attributes)
        super(attributes)
        @file_name = file_name
      end

      def image_name
        if @attributes['target']
          super
        else
          File.basename(@file_name, File.extname(@file_name))
        end
      end

      def should_process?(image_file, image_metadata)
        File.mtime(@file_name) > File.mtime(image_file) && super
      end

      def code
        @code ||= File.read(@file_name)
      end
    end
  end
end
