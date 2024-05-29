module Asciidoctor
  module Diagram
    module BatikClasspath
      JAR_FILES = Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
    end
  end
end