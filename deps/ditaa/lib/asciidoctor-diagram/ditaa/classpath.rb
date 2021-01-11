module Asciidoctor
  module Diagram
    module DitaaClasspath
      BASE_DIR = File.dirname(__FILE__)
      DITAA_JARS = Dir['*.jar', base: BASE_DIR].map { |j| File.expand_path(j, BASE_DIR) }
    end
  end
end