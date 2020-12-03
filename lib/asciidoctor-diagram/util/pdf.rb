module Asciidoctor
  module Diagram
    # @private
    module PDF
      def self.post_process_image(data, optimise)
        [data, nil, nil]
      end
    end
  end
end