require 'asciidoctor' unless defined? ::Asciidoctor::VERSION
require 'asciidoctor/extensions'
require 'digest'
require 'json'
require 'fileutils'
require_relative 'diagram_source.rb'
require_relative 'http/converter'
require_relative 'version'
require_relative 'util/java'
require_relative 'util/gif'
require_relative 'util/pdf'
require_relative 'util/png'
require_relative 'util/svg'

module Asciidoctor
  module Diagram
    # Mixin that provides the basic machinery for image generation.
    # When this module is included it will include the FormatRegistry into the singleton class of the target class.
    module DiagramProcessor
      include Asciidoctor::Logging

      module ClassMethods
        def use_converter(converter_type)
          config[:converter] = converter_type
        end
      end

      def self.included(host_class)
        host_class.use_dsl
        host_class.extend(ClassMethods)
      end

      DIAGRAM_PREFIX = 'diagram'

      IMAGE_PARAMS = {
          :svg => {
              :encoding => Encoding::UTF_8,
              :decoder => SVG
          },
          :gif => {
              :encoding => Encoding::ASCII_8BIT,
              :decoder => GIF
          },
          :png => {
              :encoding => Encoding::ASCII_8BIT,
              :decoder => PNG
          },
          :pdf => {
              :encoding => Encoding::ASCII_8BIT,
              :decoder => PDF
          }
      }

      # Processes the diagram block or block macro by converting it into an image or literal block.
      #
      # @param parent [Asciidoctor::AbstractBlock] the parent asciidoc block of the block or block macro being processed
      # @param reader_or_target [Asciidoctor::Reader, String] a reader that provides the contents of a block or the
      #        target value of a block macro
      # @param attributes [Hash] the attributes of the block or block macro
      # @return [Asciidoctor::AbstractBlock] a new block that replaces the original block or block macro
      def process(parent, reader_or_target, attributes)
        location = parent.document.reader.cursor_at_mark

        normalised_attributes = attributes.inject({}) { |h, (k, v)| h[normalise_attribute_name(k)] = v; h }
        source = create_source(parent, reader_or_target, normalised_attributes)

        converter = config[:converter].new

        supported_formats = converter.supported_formats

        begin
          format = source.attributes.delete('format') || source.attr('format', nil, name) || source.attr('format', supported_formats[0], DIAGRAM_PREFIX)
          format = format.to_sym if format.respond_to?(:to_sym)

          raise "Format undefined" unless format

          raise "#{self.class.name} does not support output format #{format}" unless supported_formats.include?(format)


          title = source.attributes.delete 'title'
          caption = source.attributes.delete 'caption'

          case format
          when :txt, :atxt, :utxt
            block = create_literal_block(parent, source, format, converter)
          else
            block = create_image_block(parent, source, format, converter)
          end

          block.title = title
          block.assign_caption(caption, 'figure')
          block
        rescue => e
          case source.attr('on-error', 'log', DIAGRAM_PREFIX)
          when 'abort'
            raise e
          else
            text = "Failed to generate image: #{e.message}"
            warn_msg = text.dup
            if $VERBOSE
              warn_msg << "\n" << e.backtrace.join("\n")
            end

            logger.error message_with_context warn_msg, source_location: location

            text << "\n"
            text << source.code
            Asciidoctor::Block.new parent, :listing, :source => text, :attributes => attributes
          end

        end
      end

      protected

      # Creates a DiagramSource object for the block or block macro being processed. Classes using this
      # mixin must implement this method.
      #
      # @param parent_block [Asciidoctor::AbstractBlock] the parent asciidoc block of the block or block macro being processed
      # @param reader_or_target [Asciidoctor::Reader, String] a reader that provides the contents of a block or the
      #        target value of a block macro
      # @param attributes [Hash] the attributes of the block or block macro
      #
      # @return [DiagramSource] an object that implements the interface described by DiagramSource
      #
      # @abstract
      def create_source(parent_block, reader_or_target, attributes)
        raise NotImplementedError.new
      end

      private

      def normalise_attribute_name(k)
        case k
        when String
          k.downcase
        when Symbol
          k.to_s.downcase.to_sym
        else
          k
        end
      end

      DIGIT_CHAR_RANGE = ('0'.ord)..('9'.ord)

      def create_image_block(parent, source, format, converter)
        image_name = "#{source.image_name}.#{format}"
        image_dir = image_output_dir(parent)
        cache_dir = cache_dir(parent)
        image_file = parent.normalize_system_path image_name, image_dir
        metadata_file = parent.normalize_system_path "#{image_name}.cache", cache_dir

        if File.exist? metadata_file
          metadata = File.open(metadata_file, 'r') {|f| JSON.load(f, nil, :symbolize_names => true, :create_additions => false) }
        else
          metadata = {}
        end

        image_attributes = source.attributes
        options = converter.collect_options(source, name)

        if !File.exist?(image_file) || source.should_process?(image_file, metadata) || options != metadata[:options]
          params = IMAGE_PARAMS[format]

          server_url = source.attr('server-url', nil, name) || source.attr('server-url', nil, DIAGRAM_PREFIX)
          if server_url
            server_type = source.attr('server-type', nil, name) || source.attr('server-type', 'plantuml', DIAGRAM_PREFIX)
            converter = HttpConverter.new(server_url, server_type.to_sym, converter)
          end

          options = converter.collect_options(source, name)
          result = converter.convert(source, format, options)

          result.force_encoding(params[:encoding])

          metadata = source.create_image_metadata
          metadata[:options] = options
          metadata[:width], metadata[:height] = params[:decoder].get_image_size(result)

          FileUtils.mkdir_p(File.dirname(image_file)) unless Dir.exist?(File.dirname(image_file))
          File.open(image_file, 'wb') {|f| f.write result}

          FileUtils.mkdir_p(File.dirname(metadata_file)) unless Dir.exist?(File.dirname(metadata_file))
          File.open(metadata_file, 'w') {|f| JSON.dump(metadata, f)}
        end

        image_attributes['target'] = source.attr('data-uri', nil, true) ? image_file : image_name
        if format == :svg
          svg_type = source.attr('svg-type', nil, name) || source.attr('svg-type', nil, DIAGRAM_PREFIX)
          image_attributes['opts'] = svg_type if svg_type && svg_type != 'static'
        end

        scale = image_attributes['scale']
        if scalematch = /(\d+(?:\.\d+))/.match(scale)
          scale_factor = scalematch[1].to_f
        else
          scale_factor = 1.0
        end

        if /html/i =~ parent.document.attributes['backend']
          image_attributes.delete('scale')
          if metadata[:width] && !image_attributes['width']
            image_attributes['width'] = (metadata[:width] * scale_factor).to_i
          end
          if metadata[:height] && !image_attributes['height']
            image_attributes['height'] = (metadata[:height] * scale_factor).to_i
          end
        end

        image_attributes['alt'] ||= if title_text = image_attributes['title']
                                      title_text
                                    elsif target = image_attributes['target']
                                      (File.basename(target, File.extname(target)) || '').tr '_-', ' '
                                    else
                                      'Diagram'
                                    end

        image_attributes['alt'] = parent.sub_specialchars image_attributes['alt']

        parent.document.register(:images, image_name)
        if (scaledwidth = image_attributes['scaledwidth'])
          # append % to scaledwidth if ends in number (no units present)
          if DIGIT_CHAR_RANGE.include?((scaledwidth[-1] || 0).ord)
            image_attributes['scaledwidth'] = %(#{scaledwidth}%)
          end
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

        images_dir = parent.attr('imagesoutdir', nil, true)

        if images_dir
          base_dir = nil
        else
          base_dir = parent.attr('outdir', nil, true) || doc_option(document, :to_dir)
          images_dir = parent.attr('imagesdir', nil, true)
        end

        parent.normalize_system_path(images_dir, base_dir)
      end

      def cache_dir(parent)
        document = parent.document
        cache_dir = '.asciidoctor/diagram'
        base_dir = parent.attr('outdir', nil, true) || doc_option(document, :to_dir)
        parent.normalize_system_path(cache_dir, base_dir)
      end

      def create_literal_block(parent, source, format, converter)
        literal_attributes = source.attributes
        literal_attributes.delete('target')

        options = converter.collect_options(source, name)
        result = converter.convert(source, format, options)

        result.force_encoding(Encoding::UTF_8)
        Asciidoctor::Block.new parent, :literal, :source => result, :attributes => literal_attributes
      end

      def doc_option(document, key)
        if document.respond_to?(:options)
          value = document.options[key]
        else
          value = nil
        end

        if document.nested? && value.nil?
          doc_option(document.parent_document, key)
        else
          value
        end
      end
    end

    # Base class for diagram block processors.
    class DiagramBlockProcessor < Asciidoctor::Extensions::BlockProcessor
      include DiagramProcessor

      def self.inherited(subclass)
        subclass.name_positional_attributes ['target', 'format']
        subclass.contexts [:listing, :literal, :open]
        subclass.content_model :simple
      end

      # Creates a ReaderSource from the given reader.
      #
      # @return [ReaderSource] a ReaderSource
      def create_source(parent_block, reader, attributes)
        ReaderSource.new(self, parent_block, reader, attributes)
      end
    end

    # Base class for diagram block macro processors.
    class DiagramBlockMacroProcessor < Asciidoctor::Extensions::BlockMacroProcessor
      include DiagramProcessor

      def self.inherited(subclass)
        subclass.name_positional_attributes ['target', 'format']
      end

      def apply_target_subs(parent, target)
        if target
          parent.normalize_system_path(parent.sub_attributes(target, :attribute_missing => 'warn'))
        else
          nil
        end
      end

      # Creates a FileSource using target as the file name.
      #
      # @return [FileSource] a FileSource
      def create_source(parent, target, attributes)
        FileSource.new(self, parent, apply_target_subs(parent, target), attributes)
      end
    end
  end
end
