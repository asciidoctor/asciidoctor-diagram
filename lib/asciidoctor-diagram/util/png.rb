require_relative 'binaryio'

module Asciidoctor
  module Diagram
    # @private
    module PNG
      PNG_SIGNATURE = String.new("\x89\x50\x4E\x47\x0D\x0A\x1A\x0A", encoding: 'ASCII-8BIT')

      def self.post_process_image(data, optimise)
        bio = BinaryIO.new(data)
        png_signature = bio.read_string(8)
        raise "Invalid PNG signature" unless png_signature == PNG_SIGNATURE

        chunk_length = bio.read_uint32_be
        chunk_type = bio.read_string(4, Encoding::US_ASCII)
        raise "Unexpected PNG chunk type '#{chunk_type}'; expected 'IHDR'" unless chunk_type == 'IHDR'
        raise "Unexpected PNG chunk length '#{chunk_length}'; expected '13'" unless chunk_length == 13

        width = bio.read_uint32_be
        height = bio.read_uint32_be
        [data, width, height]
      end
    end
  end
end