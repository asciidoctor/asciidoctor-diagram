require_relative '../diagram_converter'
require_relative '../util/cli_generator'
require 'tempfile'
require 'open3'

module Asciidoctor
  module Diagram
    # @private
    class MemeConverter
      include DiagramConverter


      def supported_formats
        [:png, :gif]
      end


      def collect_options(source)
        bg_img = source.attr('background')
        raise "background attribute is required" unless bg_img

        options = source.attr('options', '').split(',')

        {
            :bg_img => bg_img,
            :top_label => source.attr('top'),
            :bottom_label => source.attr('bottom'),
            :fill_color => source.attr(['fillcolor', 'fill-color']),
            :stroke_color => source.attr(['strokecolor', 'stroke-color']),
            :stroke_width => source.attr(['strokewidth', 'stroke-width']),
            :font => source.attr('font', 'Impact'),
            :noupcase => options.include?('noupcase'),
        }
      end

      def convert(source, format, options)
        convert = source.find_command('convert')
        identify = source.find_command('identify')

        bg_img = options[:bg_img]
        raise "background attribute is required" unless bg_img

        bg_img = source.resolve_path(bg_img, source.attr('imagesdir'))

        top_label = options[:top_label]
        bottom_label = options[:bottom_label]
        fill_color = options[:fill_color] || 'white'
        stroke_color = options[:stroke_color] || 'black'
        stroke_width = options[:stroke_width] || '2'
        font = options[:font] || 'Impact'
        noupcase = options[:noupcase]

        dimensions = Cli.run(identify, '-format', '%w %h', bg_img)[:out].match(/(?<w>\d+) (?<h>\d+)/)
        bg_width = dimensions['w'].to_i
        bg_height = dimensions['h'].to_i
        label_width = bg_width
        label_height = bg_height / 5

        if top_label
          top_img = Tempfile.new(['meme', '.png'])
          Cli.run(
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
          Cli.run(
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
          args << top_img.path << '-geometry' << '+0+0' << '-composite'
        end

        if bottom_img
          args << bottom_img.path << '-geometry' << "+0+#{bg_height - label_height}" << '-composite'
        end

        args << final_img.path

        Cli.run(*args)

        File.binread(final_img)
      end

      private

      def prepare_label(label, noupcase)
        label = label.upcase unless noupcase
        label = label.gsub(' // ', '\n')
        label
      end
    end
  end
end
