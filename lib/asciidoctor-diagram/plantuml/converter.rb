module Asciidoctor
  module Diagram
    # @private
    module PlantUmlConverter
      JARS = %w[plantuml-1.3.13.jar plantuml.jar jlatexmath-minimal-1.0.5.jar batik-all-1.10.jar].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def convert(source, opts)
        headers = {}
        headers['Accept'] = opts['mime_type']
        headers['X-PlantUML-Config'] = opts['config_file'] if opts['config_file']
        headers['X-Graphviz'] = opts['graphviz_bin_path'] if opts['graphviz_bin_path']
        send_request(source, headers)
      end

      private

      def send_request(body, headers, url = '/plantuml')
        Java.load
        response = Java.send_request(
          url: url,
          body: body,
          headers: headers
        )
        unless response[:code] == 200
          raise Java.create_error('PlantUML image generation failed', response)
        end
        response[:body]
      end
    end
  end
end