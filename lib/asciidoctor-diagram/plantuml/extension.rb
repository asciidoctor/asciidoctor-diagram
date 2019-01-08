require_relative '../extensions'
require_relative '../util/which'
require_relative 'converter'
require 'uri'

module Asciidoctor
  module Diagram
    # @private
    module PlantUml
      include Which
      include PlantUmlConverter

      private

      def plantuml(parent_block, source, tag, mime_type)
        inherit_prefix = name
        code = preprocess_code(parent_block, source, tag)
        opts = prepare_options(inherit_prefix, mime_type, parent_block, source)
        convert(code, opts)
      end

      def prepare_options(inherit_prefix, mime_type, parent_block, source)
        opts = {}
        opts['mime_type'] = mime_type
        config_file = source.attr('plantumlconfig', nil, true) || source.attr('config', nil, inherit_prefix)
        if config_file
          opts['config_file'] = File.expand_path(config_file, source.attr('docdir', nil, true))
        end
        dot = which(parent_block, 'dot', alt_attrs: ['graphvizdot'], raise_on_error: false)
        if dot
          opts['graphviz_bin_path'] = ::Asciidoctor::Diagram::Platform.host_os_path(dot)
        end
        opts
      end

      def preprocess_code(parent, source, tag)
        code = source.to_s
        base_dir = source.base_dir

        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index "@start#{tag}"

        code.gsub!(/(?<=<img:)[^>]+(?=>)/) do |match|
          resolve_path(match, parent, parent.attr('imagesdir'))
        end

        code.gsub!(/(?<=!include )\s*[^<][^!\n\r]+/) do |match|
          resolve_path(match.lstrip, parent, base_dir)
        end

        code
      end

      def resolve_path(path, parent, base_dir)
        if path =~ ::URI::ABS_URI
          uri = ::URI.parse(path)
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
        mod.register_format(:png, :image) do |parent_block, source|
          plantuml(parent_block, source, mod.tag, 'image/png')
        end
        mod.register_format(:svg, :image) do |parent_block, source|
          plantuml(parent_block, source, mod.tag, 'image/svg+xml')
        end
        mod.register_format(:txt, :literal) do |parent_block, source|
          plantuml(parent_block, source, mod.tag, 'text/plain;charset=utf-8')
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
