require_relative 'binaryio'

module Asciidoctor
  module PlantUml
    module SVG
      SVG_SIZE_REGEX = /style="width:(?<width>\d+)px;height:(?<height>\d+)px/

      def self.get_image_size(data)
        match_data = SVG_SIZE_REGEX.match(data)
        if match_data
          [match_data[:width].to_i, match_data[:height].to_i]
        else
          nil
        end
      end
    end
  end
end