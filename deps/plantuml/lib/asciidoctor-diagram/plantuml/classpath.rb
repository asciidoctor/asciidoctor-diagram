module Asciidoctor
  module Diagram
    module PlantUmlClasspath
      BASE_DIR = File.dirname(__FILE__)
      PLANTUML_JARS = Dir['*.jar', base: BASE_DIR].map { |j| File.expand_path(j, BASE_DIR) }
    end
  end
end