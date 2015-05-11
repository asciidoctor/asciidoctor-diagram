require 'asciidoctor/extensions'
require 'digest'
require 'json'
require 'fileutils'
require_relative 'util/java'
require_relative 'util/png'
require_relative 'util/svg'

module Asciidoctor
  module Diagram
    module Extensions
      # Provides the means for diagram processors to register supported output formats and image
      # generation routines
      module FormatRegistry
        # Registers a supported format. The first registered format becomes the default format for the block
        # processor.
        #
        # @param [Symbol] format the format name
        # @param [Symbol] type a symbol indicating the type of block that should be generated; either :image or :literal
        # @yieldparam parent [Asciidoctor::AbstractNode] the asciidoc block that is being processed
        # @yieldparam source [DiagramSource] the source object
        # @yieldreturn [String] the generated diagram
        #
        # Examples
        #
        #   register_format(:png, :image ) do |parent, source|
        #     File.read(source.to_s)
        #   end
        def register_format(format, type, &block)
          raise "Unsupported output type: #{type}" unless type == :image || type == :literal

          unless @default_format
            @default_format = format
          end

          formats[format] = {
              :type => type,
              :generator => block
          }
       end

        # Returns the registered formats
        #
        # @return [Hash]
        # @api private
        def formats
          @formats ||= {}
        end

        # Returns the default format
        #
        # @return [Symbol] the default format
        # @api private
        def default_format
          @default_format
        end
      end

      # Mixin that provides the basic machinery for image generation.
      # When this module is included it will include the FormatRegistry into the singleton class of the target class.
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

        def self.included(mod)
          class << mod
            include FormatRegistry
          end
        end

        # Processes the diagram block or block macro by converting it into an image or literal block.
        #
        # @param parent [Asciidoctor::AbstractBlock] the parent asciidoc block of the block or block macro being processed
        # @param reader_or_target [Asciidoctor::Reader, String] a reader that provides the contents of a block or the
        #        target value of a block macro
        # @param attributes [Hash] the attributes of the block or block macro
        # @return [Asciidoctor::AbstractBlock] a new block that replaces the original block or block macro
        def process(parent, reader_or_target, attributes)
          source = create_source(parent, reader_or_target, attributes.dup)

          format = source.attributes.delete('format') || self.class.default_format
          format = format.to_sym if format.respond_to?(:to_sym)

          raise "Format undefined" unless format

          generator_info = self.class.formats[format]

          raise "#{self.class.name} does not support output format #{format}" unless generator_info

          begin
            case generator_info[:type]
              when :literal
                create_literal_block(parent, source, generator_info)
              else
                create_image_block(parent, source, format, generator_info)
            end
          rescue => e
            text = "Failed to generate image: #{e.message}"
            warn %(asciidoctor-diagram: ERROR: #{text})
            text << "\n"
            text << source.code
            Asciidoctor::Block.new parent, :listing, :source => text, :attributes => attributes
          end
        end

        protected

        # Creates a DiagramSource object for the block or block macro being processed. Classes using this
        # mixin must implement this method.
        #
        # @param parent [Asciidoctor::AbstractBlock] the parent asciidoc block of the block or block macro being processed
        # @param reader_or_target [Asciidoctor::Reader, String] a reader that provides the contents of a block or the
        #        target value of a block macro
        # @param attributes [Hash] the attributes of the block or block macro
        #
        # @return [DiagramSource] an object that implements the interface described by DiagramSource
        #
        # @abstract
        def create_source(parent, reader_or_target, attributes)
          raise NotImplementedError.new
        end

        private
        def create_image_block(parent, source, format, generator_info)
          image_name = "#{source.image_name}.#{format}"
          image_dir = image_output_dir(parent)
          image_file = parent.normalize_system_path image_name, image_dir
          metadata_file = parent.normalize_system_path "#{image_name}.cache", image_dir

          if File.exists? metadata_file
            metadata = File.open(metadata_file, 'r') { |f| JSON.load f }
          else
            metadata = {}
          end

          image_attributes = source.attributes

          if !File.exists?(image_file) || source.should_process?(image_file, metadata)
            params = IMAGE_PARAMS[format]

            result = instance_exec(source, parent, source, &generator_info[:generator])

            result.force_encoding(params[:encoding])

            metadata = source.create_image_metadata
            metadata['width'], metadata['height'] = params[:decoder].get_image_size(result)

            FileUtils.mkdir_p(image_dir) unless Dir.exists?(image_dir)
            File.open(image_file, 'wb') { |f| f.write result }
            File.open(metadata_file, 'w') { |f| JSON.dump(metadata, f) }
          end

          image_attributes['target'] = image_name

          scale = image_attributes['scale']
          if scalematch = /(\d+(?:\.\d+))/.match(scale)
            scale_factor = scalematch[1].to_f
          else
            scale_factor = 1.0
          end

          if /html/i =~ parent.document.attributes['backend']
            image_attributes.delete('scale')
            if metadata['width'] && !image_attributes['width']
              image_attributes['width'] = (metadata['width'] * scale_factor).to_i
            end
            if metadata['height'] && !image_attributes['height']
              image_attributes['height'] = (metadata['height'] * scale_factor).to_i
            end
          end

          image_attributes['alt'] ||= if title_text = image_attributes['title']
                                        title_text
                                      elsif target = image_attributes['target']
                                        (File.basename(target, File.extname(target)) || '').tr '_-', ' '
                                      else
                                        'Diagram'
                                      end

          Asciidoctor::Block.new parent, :image, :content_model => :empty, :attributes => image_attributes
        end

        def scale(size, factor)
          if match = /(\d+)(.*)/.match(size)
            value = match[1].to_i
            unit = match[2]
            (value * factor).to_i.to_s + unit
          else
            size
          end
        end

        def image_output_dir(parent)
          document = parent.document

          images_dir = document.attr('imagesoutdir')

          if images_dir
            base_dir = nil
          else
            base_dir = document.attr('outdir') || (document.respond_to?(:options) && document.options[:to_dir])
            images_dir = document.attr('imagesdir')
          end

          parent.normalize_system_path(images_dir, base_dir)
        end

        def create_literal_block(parent, source, generator_info)
          literal_attributes = source.attributes
          literal_attributes.delete('target')

          result = instance_exec(source, parent, &generator_info[:generator])

          result.force_encoding(Encoding::UTF_8)
          Asciidoctor::Block.new parent, :literal, :source => result, :attributes => literal_attributes
        end
      end

      # Base class for diagram block processors.
      class DiagramBlockProcessor < Asciidoctor::Extensions::BlockProcessor
        include DiagramProcessor

        def self.inherited(subclass)
          subclass.option :pos_attrs, ['target', 'format']
          subclass.option :contexts, [:listing, :literal, :open]
          subclass.option :content_model, :simple
        end

        # Creates a ReaderSource from the given reader.
        #
        # @return [ReaderSource] a ReaderSource
        def create_source(parent, reader, attributes)
          ReaderSource.new(reader, attributes)
        end
      end

      # Base class for diagram block macro processors.
      class DiagramBlockMacroProcessor < Asciidoctor::Extensions::BlockMacroProcessor
        include DiagramProcessor

        def self.inherited(subclass)
          subclass.option :pos_attrs, ['target', 'format']
        end

        # Creates a FileSource using target as the file name.
        #
        # @return [FileSource] a FileSource
        def create_source(parent, target, attributes)
          FileSource.new(File.expand_path(target, parent.document.base_dir), attributes)
        end
      end

      # This module describes the duck-typed interface that diagram sources must implement. Implementations
      # may include this module but it is not required.
      module DiagramSource
        # @return [String] the base name for the image file that will be produced
        # @abstract
        def image_name
          raise NotImplementedError.new
        end

        # @return [String] the String representation of the source code for the diagram
        # @abstract
        def code
          raise NotImplementedError.new
        end

        # Alias for code
        def to_s
          code
        end

        # Determines if the diagram should be regenerated or not. The default implementation of this method simply
        # returns true.
        #
        # @param image_file [String] the path to the previously generated version of the image
        # @param image_metadata [Hash] the image metadata Hash that was stored during the previous diagram generation pass
        # @return [Boolean] true if the diagram should be regenerated; false otherwise
        def should_process?(image_file, image_metadata)
          true
        end

        # Creates an image metadata Hash that will be stored to disk alongside the generated image file. The contents
        # of this Hash are reread during subsequent document processing and then passed to the should_process? method
        # where it can be used to determine if the diagram should be regenerated or not.
        # The default implementation returns an empty Hash.
        # @return [Hash] a Hash containing metadata
        def create_image_metadata
          {}
        end
      end

      # Base class for diagram source implementations that uses an md5 checksum of the source code of a diagram to
      # determine if it has been updated or not.
      class BasicSource
        include DiagramSource

        attr_reader :attributes

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

      # A diagram source that retrieves the code for the diagram from the contents of a block.
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

      # A diagram source that retrieves the code for a diagram from an external source file.
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
          File.mtime(@file_name) > File.mtime(image_file) || super
        end

        def code
          lines = File.readlines(@file_name)
          lines = ::Asciidoctor::Helpers.normalize_lines(lines)
          @code ||= lines.join("\n")
        end
      end
    end
  end
end
