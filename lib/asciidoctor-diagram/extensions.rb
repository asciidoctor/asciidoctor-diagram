require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

module Asciidoctor
  module Diagram
    module Extensions
      if RUBY_ENGINE != 'opal'
        def self.register &block
          Asciidoctor::Extensions.register &block
        end
      else
        def self.register &block
          @register_blocks ||= []
          @register_blocks << block
        end

        def self.group(register_blocks)
          proc do
            register_blocks.each do |b|
              instance_exec(&b)
            end
            nil
          end
        end

        def self.key
          :tabs
        end

        def self.register_all registry = nil
          (registry || ::Asciidoctor::Extensions).groups[key] ||= group(@register_blocks || [])
        end

        def self.unregister_all registry = nil
          (registry || ::Asciidoctor::Extensions).groups.delete key
          nil
        end
      end
    end
  end
end