module Asciidoctor
  module Diagram
    # @private
    module PDF
      def self.post_process_image(data)
        [data, nil, nil]
      end
    end
  end
end