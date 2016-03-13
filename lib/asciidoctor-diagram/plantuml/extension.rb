require_relative '../extensions'
require_relative '../util/which'

module Asciidoctor
  module Diagram
    # @private
    module PlantUml
      include Which

      private

      JARS = ['plantuml.jar'].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def plantuml(parent, code, tag, mime_type)
        Java.load

        code = preprocess_code(parent, code, tag)

        headers = {
            'Accept' => mime_type
        }

        config_file = parent.document.attributes['plantumlconfig']
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, parent.document.attributes['docdir'])
        end

        dot = which(parent, 'dot', :alt_attrs => ['graphvizdot'], :raise_on_error => false)
        if dot
          headers['X-Graphviz'] = dot
        end

        response = Java.send_request(
            :url => '/plantuml',
            :body => code,
            :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("PlantUML image generation failed", response)
        end

        response[:body]
      end

      def preprocess_code(parent, code, tag)
        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index "@start#{tag}"

        code.gsub!(/(?<=<img:)[^>]+(?=>)/) do |match|
          if match =~ URI.regexp
            uri = URI.parse(match)
            if uri.scheme == 'file'
              parent.normalize_system_path(uri.path, parent.attr('imagesdir'))
            else
              parent.normalize_web_path(match)
            end
          else
            parent.normalize_system_path(match, parent.attr('imagesdir'))
          end
        end

        code
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |c, p|
          plantuml(p, c.to_s, mod.tag, 'image/png')
        end
        mod.register_format(:svg, :image) do |c, p|
          plantuml(p, c.to_s, mod.tag, 'image/svg+xml')
        end
        mod.register_format(:txt, :literal) do |c, p|
          plantuml(p, c.to_s, mod.tag, 'text/plain;charset=utf-8')
        end
      end
    end

    class PlantUmlBlockProcessor < Extensions::DiagramBlockProcessor
      def self.tag
        'uml'
      end

      include PlantUml
    end

    class PlantUmlBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      def self.tag
        'uml'
      end

      include PlantUml
    end

    class SaltBlockProcessor < Extensions::DiagramBlockProcessor
      def self.tag
        'salt'
      end

      include PlantUml
    end

    class SaltBlockMacroProcessor < Extensions::DiagramBlockMacroProcessor
      def self.tag
        'salt'
      end

      include PlantUml
    end
  end
end
