module Asciidoctor
  module Diagram
    # This module describes the duck-typed interface that diagram converters must implement. Implementations
    # may include this module but it is not required.
    module DiagramConverter
      def supported_formats
        raise NotImplementedError.new
      end

      def collect_options(source)
        raise NotImplementedError.new
      end

      def convert(source, format, options)
        raise NotImplementedError.new
      end
    end
  end
end