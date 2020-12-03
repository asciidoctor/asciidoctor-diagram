require_relative 'binaryio'
require 'rexml/document'

module Asciidoctor
  module Diagram
    # @private
    module SVG
      def self.post_process_image(data, optimise)
        svg = REXML::Document.new(data)

        root = svg.root

        unless root.attributes['xmlns']
          root.add_attribute('xmlns', 'http://www.w3.org/2000/svg')
        end

        unless root.attributes['preserveAspectRatio']
          root.add_attribute('preserveAspectRatio', 'xMidYMid meet')
        end

        width = nil
        height = nil

        if (w = WIDTH_HEIGHT_REGEX.match(root.attributes['width'])) && (h = WIDTH_HEIGHT_REGEX.match(root.attributes['height']))
          width = to_numeric(w[:value]) * to_px_factor(w[:unit])
          height = to_numeric(h[:value]) * to_px_factor(h[:unit])
        end

        viewbox = root.attributes['viewBox']
        if (v = VIEWBOX_REGEX.match(viewbox)) && width.nil? && height.nil?
          width = to_numeric(v[:width])
          height = to_numeric(v[:height])
        end

        if viewbox.nil? && width && height
          root.add_attribute('viewBox', "0 0 #{width.to_s} #{height.to_s}")
        end

        indent = 2
        if optimise
          remove_comments(svg)
          indent = -1
        end

        patched_svg = ""
        svg.write(:output => patched_svg, :indent => indent, :transitive => true)

        [patched_svg, width, height]
      end

      private

      def self.remove_comments(parent)
        comments = []

        parent.each do |child|
          case child
            when REXML::Comment
              comments << child
            when REXML::Parent
              remove_comments(child)
          end
        end

        comments.each do |c|
          c.remove
        end
      end

      def self.to_numeric(text)
        if text.include? '.'
          text.to_f
        else
          text.to_i
        end
      end

      WIDTH_HEIGHT_REGEX = /^\s*(?<value>\d+(?:\.\d+)?)\s*(?<unit>[a-zA-Z]+)?\s*$/
      VIEWBOX_REGEX = /^\s*\d+(?:\.\d+)?\s*\d+(?:\.\d+)?\s*(?<width>\d+(?:\.\d+)?)\s*(?<height>\d+(?:\.\d+)?)\s*$/

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