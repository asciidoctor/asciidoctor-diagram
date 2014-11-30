require_relative '../extensions'

module Asciidoctor
  module Diagram
    # @private
    module PlantUml
      private

      JARS = ['plantuml.jar'].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def plantuml(parent, code, tag, mime_type)
        Java.load

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index "@start#{tag}"

        headers = {
            'Accept' => mime_type
        }

        config_file = parent.document.attributes['plantumlconfig']
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, parent.document.attributes['docdir'])
        end

        response = Java.send_request(
            :url => '/plantuml',
            :body => code,
            :headers => headers
        )

        unless response[:code] == 200
          raise "PlantUML image generation failed: #{response[:reason]} #{response[:body]}"
        end

        response[:body]
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |c, p|
          plantuml(p, c.to_s, 'uml', 'image/png')
        end
        mod.register_format(:svg, :image) do |c, p|
          plantuml(p, c.to_s, 'uml', 'image/svg+xml')
        end
        mod.register_format(:txt, :literal) do |c, p|
          plantuml(p, c.to_s, 'uml', 'text/plain;charset=utf-8')
        end
      end
    end

    class PlantUmlBlockProcessor < Extensions::DiagramBlockProcessor
      include PlantUml
    end

    class PlantUmlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      include PlantUml
    end
  end
end
