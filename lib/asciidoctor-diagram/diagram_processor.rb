require 'asciidoctor' unless defined? ::Asciidoctor::VERSION
require 'asciidoctor/extensions'
require 'digest'
require 'json'
require 'fileutils'
require 'pathname'
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
        converter = config[:converter].new

        source = converter.wrap_source(create_source(parent, reader_or_target, normalised_attributes))

        supported_formats = converter.supported_formats

        begin
          format = source.attributes.delete('format') || source.global_attr('format', supported_formats[0])
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
          case source.global_attr('on-error', 'log')
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

        image_file = parent.normalize_system_path(image_name, image_output_dir(parent))
        metadata_file = parent.normalize_system_path("#{image_name}.cache", cache_dir(source, parent))

        if File.exist? metadata_file
          metadata = File.open(metadata_file, 'r') {|f| JSON.load(f, nil, :symbolize_names => true, :create_additions => false) }
        else
          metadata = {}
        end

        image_attributes = source.attributes
        options = converter.collect_options(source)

        if !File.exist?(image_file) || source.should_process?(image_file, metadata) || options != metadata[:options]
          params = IMAGE_PARAMS[format]

          server_url = source.global_attr('server-url')
          if server_url
            server_type = source.global_attr('server-type')
            converter = HttpConverter.new(server_url, server_type.to_sym, converter)
          end

          options = converter.collect_options(source)
          result = converter.convert(source, format, options)

          result.force_encoding(params[:encoding])

          metadata = source.create_image_metadata
          metadata[:options] = options

          allow_image_optimisation = source.attr('optimise', 'true') == 'true'
          result, metadata[:width], metadata[:height] = params[:decoder].post_process_image(result, allow_image_optimisation)

          FileUtils.mkdir_p(File.dirname(image_file)) unless Dir.exist?(File.dirname(image_file))
          File.open(image_file, 'wb') {|f| f.write result}

          FileUtils.mkdir_p(File.dirname(metadata_file)) unless Dir.exist?(File.dirname(metadata_file))
          File.open(metadata_file, 'w') {|f| JSON.dump(metadata, f)}
        end

        scale = image_attributes['scale']
        if !converter.native_scaling? && scalematch = /([0-9]+(?:\.[0-9]+)?)/.match(scale)
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

        parent.document.register(:images, image_name)

        node = Asciidoctor::Block.new parent, :image, :content_model => :empty, :attributes => image_attributes

        alt_text = node.attr('alt')
        alt_text ||= if title_text = image_attributes['title']
                       title_text
                     elsif target = image_attributes['target']
                       (File.basename(target, File.extname(target)) || '').tr '_-', ' '
                     else
                       'Diagram'
                     end
        alt_text = parent.sub_specialchars(alt_text)

        node.set_attr('alt', alt_text)

        if (scaledwidth = node.attr('scaledwidth'))
          # append % to scaledwidth if ends in number (no units present)
          if DIGIT_CHAR_RANGE.include?((scaledwidth[-1] || 0).ord)
            node.set_attr('scaledwidth', %(#{scaledwidth}%))
          end
        end

        use_absolute_path = source.attr('data-uri', nil, true)

        if format == :svg
          svg_type = source.global_attr('svg-type')
          case svg_type
            when nil, 'static'
            when 'inline', 'interactive'
              node.set_option(svg_type)
              use_absolute_path = true
            else
              raise "Unsupported SVG type: #{svg_type}"
          end
        end

        if use_absolute_path
          node.set_attr('target', image_file)
        else
          node.set_attr('target', image_name)

          if source.global_attr('autoimagesdir')
            image_path = Pathname.new(image_file)
            output_path = Pathname.new(parent.normalize_system_path(output_dir(parent)))

            imagesdir = image_path.relative_path_from(output_path).dirname.to_s
            node.set_attr('imagesdir', imagesdir)
          end
        end

        node
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

      # Returns the image output directory as an absolute path
      def image_output_dir(parent)
        images_out_dir = parent.attr('imagesoutdir', nil, true)

        if images_out_dir
          resolve_path(parent, images_out_dir)
        else
          images_dir = parent.attr('imagesdir', nil, true)
          output_dir = output_dir(parent)
          resolve_path(parent, images_dir, output_dir)
        end
      end

      # Returns the cache directory as an absolute path
      def cache_dir(source, parent)
        cache_dir = source.global_attr('cachedir')
        if cache_dir
          resolve_path(parent, cache_dir)
        else
          output_dir = output_dir(parent)
          resolve_path(parent, '.asciidoctor/diagram', output_dir)
        end
      end

      # Returns the general output directory for Asciidoctor as an absolute path
      def output_dir(parent)
        resolve_path(parent, parent.attr('outdir', nil, true) || doc_option(parent.document, :to_dir))
      end

      def resolve_path(parent, path, base_dir = nil)
        if path.nil?
          # Resolve the base dir itself
          parent.document.path_resolver.system_path(base_dir)
        else
          # Resolve the path with respect to the base dir
          parent.document.path_resolver.system_path(path, base_dir)
        end
      end

      def create_literal_block(parent, source, format, converter)
        literal_attributes = source.attributes
        literal_attributes.delete('target')

        options = converter.collect_options(source)
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
        subclass.name_positional_attributes ['format']
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
