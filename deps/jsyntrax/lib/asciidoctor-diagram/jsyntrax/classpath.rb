module Asciidoctor
  module Diagram
    module JsyntraxClasspath
      JAR_FILES = Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
    end
  end
end