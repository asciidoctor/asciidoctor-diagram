require_relative '../extensions'
require_relative '../util/cli_generator'
require_relative '../util/which'
require 'tempfile'
require 'open3'

module Asciidoctor
  module Diagram
    # @private
    module Meme
      include Which

      def self.included(mod)
        [:png, :gif].each do |format|
          mod.register_format(format, :image) do |parent, source|
            meme(parent, source, format)
          end
        end
      end

      def meme(p, c, format)
        convert = which(p, 'convert')
        identify = which(p, 'identify')

        bg_img = c.attr('background')
        raise "background attribute is required" unless bg_img

        bg_img = p.normalize_system_path(bg_img, p.attr('imagesdir'))

        top_label = c.attr('top')
        bottom_label = c.attr('bottom')
        fill_color = c.attr('fillColor', 'white')
        stroke_color = c.attr('strokeColor', 'black')
        stroke_width = c.attr('strokeWidth', '2')
        font = c.attr('font', 'Impact')
        options = c.attr('options', '').split(',')
        noupcase = options.include?('noupcase')

        dimensions = CliGenerator.run_cli(identify, '-format', '%w %h', bg_img).match(/(?<w>\d+) (?<h>\d+)/)
        bg_width = dimensions['w'].to_i
        bg_height = dimensions['h'].to_i
        label_width = bg_width
        label_height = bg_height / 5

        if top_label
          top_img = Tempfile.new(['meme', '.png'])
          CliGenerator.run_cli(
              convert,
              '-background', 'none',
              '-fill', fill_color,
              '-stroke', stroke_color,
              '-strokewidth', stroke_width,
              '-font', font,
              '-size', "#{label_width}x#{label_height}",
              '-gravity', 'north',
              "label:#{prepare_label(top_label, noupcase)}",
              top_img.path
          )
        else
          top_img = nil
        end

        if bottom_label
          bottom_img = Tempfile.new(['meme', '.png'])
          CliGenerator.run_cli(
              convert,
              '-background', 'none',
              '-fill', fill_color,
              '-stroke', stroke_color,
              '-strokewidth', stroke_width,
              '-font', font,
              '-size', "#{label_width}x#{label_height}",
              '-gravity', 'south',
              "label:#{prepare_label(bottom_label, noupcase)}",
              bottom_img.path
          )
        else
          bottom_img = nil
        end

        final_img = Tempfile.new(['meme', ".#{format.to_s}"])

        args = [convert, bg_img]
        if top_img
          args << top_img.path << '-geometry'<< '+0+0' << '-composite'
        end

        if bottom_img
          args << bottom_img.path << '-geometry'<< "+0+#{bg_height - label_height}" << '-composite'
        end

        args << final_img.path

        CliGenerator.run_cli(*args)

        File.binread(final_img)
      end

      private
      def prepare_label(label, noupcase)
        label = label.upcase unless noupcase
        label = label.gsub(' // ', '\n')
        label
      end
    end

    class MemeBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Meme

      option :pos_attrs, %w(top bottom target format)

      def create_source(parent, target, attributes)
        attributes = attributes.dup
        attributes['background'] = target
        ::Asciidoctor::Diagram::Extensions::FileSource.new(parent, nil, attributes)
      end
    end
  end
end
