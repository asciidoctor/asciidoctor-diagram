require_relative '../diagram_converter'
require 'uri'

module Asciidoctor
  module Diagram
    # @private
    class PlantUmlConverter
      include DiagramConverter

      JARS = [
          'plantuml-1.3.15.jar',
          'plantuml.jar',
          'jlatexmath-minimal-1.0.5.jar',
          'batik-all-1.10.jar'
      ].map do |jar|
        File.expand_path File.join('../..', jar), File.dirname(__FILE__)
      end
      Java.classpath.concat JARS

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        {
            :config => source.attr('plantumlconfig', nil, true) || source.attr('config')
        }
      end

      def convert(source, format, options)
        Java.load

        code = preprocess_code(source, self.class.tag)

        case format
        when :png
          mime_type = 'image/png'
        when :svg
          mime_type = 'image/svg+xml'
        when :txt, :utxt
          mime_type = 'text/plain;charset=utf-8'
        when :atxt
          mime_type = 'text/plain'
        else
          raise "Unsupported format: #{format}"
        end

        headers = {
            'Accept' => mime_type
        }

        config_file = options[:config]
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, source.base_dir)
        end

        dot = source.find_command('dot', :alt_attrs => ['graphvizdot'], :raise_on_error => false)
        if dot
          headers['X-Graphviz'] = ::Asciidoctor::Diagram::Platform.host_os_path(dot)
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

      def preprocess_code(source, tag)
        code = source.to_s

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index("@start") && code.index("@end")

        code.gsub!(/(?<=<img:)[^>]+(?=>)/) do |match|
          resolve_path(match, source, source.attr('imagesdir', nil, false))
        end

        code.gsub!(/(?:(?<=!include\s)|(?<=!includesub\s))\s*[^<][^!\n\r]+/) do |match|
          resolve_path(match.lstrip, source, source.base_dir)
        end

        code
      end

      def resolve_path(path, source, base_dir)
        if path =~ ::URI::ABS_URI
          uri = ::URI.parse(path)
          if uri.scheme == 'file'
            source.resolve_path(uri.path, base_dir)
          else
            path
          end
        else
          source.resolve_path(path, base_dir)
        end
      end
    end

    class UmlConverter < PlantUmlConverter
      def self.tag
        'uml'
      end
    end

    class SaltConverter < PlantUmlConverter
      def self.tag
        'salt'
      end
    end
  end
end
