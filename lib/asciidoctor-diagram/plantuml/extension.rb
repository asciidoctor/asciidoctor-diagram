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

      def plantuml(parent, source, tag, mime_type)
        Java.load

        code = preprocess_code(parent, source, tag)

        headers = {
            'Accept' => mime_type
        }

        config_file = parent.attr('plantumlconfig', nil, true)
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, parent.attr('docdir', nil, true))
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

      def preprocess_code(parent, source, tag)
        code = source.to_s
        base_dir = source.base_dir

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index "@start#{tag}"

        code.gsub!(/(?<=<img:)[^>]+(?=>)/) do |match|
          resolve_path(match, parent, parent.attr('imagesdir'))
        end

        code.gsub!(/(?<=!include )[^!\n\r]+/) do |match|
          resolve_path(match, parent, base_dir)
        end

        code
      end

      def resolve_path(path, parent, base_dir)
        if path =~ URI.regexp
          uri = URI.parse(path)
          if uri.scheme == 'file'
            parent.normalize_system_path(uri.path, base_dir)
          else
            parent.normalize_web_path(path)
          end
        else
          parent.normalize_system_path(path, base_dir)
        end
      end

      def self.included(mod)
        mod.register_format(:png, :image) do |parent, source|
          plantuml(parent, source, mod.tag, 'image/png')
        end
        mod.register_format(:svg, :image) do |parent, source|
          plantuml(parent, source, mod.tag, 'image/svg+xml')
        end
        mod.register_format(:txt, :literal) do |parent, source|
          plantuml(parent, source, mod.tag, 'text/plain;charset=utf-8')
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
