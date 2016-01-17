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
        mod.register_format(:png, :image) do |c, p|
          convert = which(p, 'convert')
          identify = which(p, 'identify')

          attrs = c.attributes
          bg_img = attrs["background"]
          raise "background attribute is required" unless bg_img

          bg_img = p.normalize_system_path(bg_img, p.document.base_dir)

          top_label = attrs["top"]
          bottom_label = attrs["bottom"]
          fill_color = attrs.fetch('fillColor', 'white')
          stroke_color = attrs.fetch('strokeColor', 'black')
          stroke_width = attrs.fetch('strokeWidth', '2')
          font = attrs.fetch('font', 'Impact')

          dimensions = CliGenerator.run_cli(identify, '-format', '"%w %h"', bg_img).match /(?<w>\d+) (?<h>\d+)/
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
                "label:#{top_label}",
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
                "label:#{bottom_label}",
                bottom_img.path
            )
          else
            bottom_img = nil
          end

          final_img = Tempfile.new(['meme', '.png'])

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
      end
    end

    class MemeBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include Meme
    end
  end
end