require 'asciidoctor/extensions'
require_relative 'asciidoctor-plantuml/version'

Asciidoctor::Extensions.register do
  require 'asciidoctor-plantuml/extension'
  block :plantuml, Asciidoctor::PlantUml::Block
end
