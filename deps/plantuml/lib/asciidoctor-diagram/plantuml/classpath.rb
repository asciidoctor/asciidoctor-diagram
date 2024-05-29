require 'asciidoctor-diagram/batik/classpath'

module Asciidoctor
  module Diagram
    module PlantUmlClasspath
      JAR_FILES = (Dir[File.join(File.dirname(__FILE__), '*.jar')] + Asciidoctor::Diagram::BatikClasspath::JAR_FILES).freeze
    end
  end
end