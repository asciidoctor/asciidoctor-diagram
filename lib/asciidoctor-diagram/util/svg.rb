require_relative 'binaryio'

module Asciidoctor
  module Diagram
    module SVG
      def self.get_image_size(data)
        get_from_style(data) || get_from_viewport(data)
      end

      private

      SVG_STYLE_REGEX = /style\s*=\s*"width:(?<width>\d+)px;height:(?<height>\d+)px/

      def self.get_from_style(data)
        match_data = SVG_STYLE_REGEX.match(data)
        if match_data
          [match_data[:width].to_i, match_data[:height].to_i]
        else
          nil
        end
      end

      SVG_VIEWPORT_REGEX = /<svg width="(?<width>\d+)(?<width_unit>[a-zA-Z]+)" height="(?<height>\d+)(?<height_unit>[a-zA-Z]+)"/

      def self.get_from_viewport(data)
        match_data = SVG_VIEWPORT_REGEX.match(data)
        if match_data
          width = match_data[:width].to_i * to_px_factor(match_data[:width_unit])
          height = match_data[:height].to_i * to_px_factor(match_data[:height_unit])
          [width.to_i, height.to_i]
        else
          nil
        end
      end

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