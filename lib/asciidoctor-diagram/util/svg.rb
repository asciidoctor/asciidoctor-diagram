require_relative 'binaryio'
require 'rexml/document'

module Asciidoctor
  module Diagram
    # @private
    module SVG
      def self.post_process_image(data)
        svg = REXML::Document.new(data)

        root = svg.root
        unless root.attributes['preserveAspectRatio']
          root.add_attribute('preserveAspectRatio', 'xMidYMid meet')
        end

        width = nil
        height = nil

        if (w = WIDTH_HEIGHT_REGEX.match(root.attributes['width'])) && (h = WIDTH_HEIGHT_REGEX.match(root.attributes['height']))
          width = w[:value].to_i * to_px_factor(w[:unit])
          height = h[:value].to_i * to_px_factor(h[:unit])
        end

        viewbox = root.attributes['viewBox']
        if (v = VIEWBOX_REGEX.match(viewbox) && width.nil? && height.nil?)
          width = v[:width]
          height = v[:height]
        end

        if viewbox.nil? && width && height
          root.add_attribute('viewBox', "0 0 #{width} #{height}")
        end

        patched_svg = ""
        svg.write(:output => patched_svg, :indent => 2)

        [patched_svg, width, height]
      end

      private

      WIDTH_HEIGHT_REGEX = /^\s*(?<value>\d+(?:\.\d+)?)\s*(?<unit>[a-zA-Z]+)?\s*$/
      VIEWBOX_REGEX = /^\s*\d+(?:\.\d+)?\s*\d+(?:\.\d+)?\s*(?<width>\d+(?:\.\d+)?)\s*(?<height>\d+(?:\.\d+)?)^\s*$/

      def self.to_px_factor(unit)
        case unit
          when 'pt'
            1.33
          else
            1
        end
      end
    end
  end
end