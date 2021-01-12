module Asciidoctor
  module Diagram
    module PlantUmlClasspath
      JAR_FILES = Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
    end
  end
end