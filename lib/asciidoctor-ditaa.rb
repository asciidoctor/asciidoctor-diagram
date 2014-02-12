require 'asciidoctor/extensions'
require_relative 'asciidoctor-diagrams/version'

Asciidoctor::Extensions.register do
  require 'asciidoctor-diagrams/ditaa'
  block :ditaa, Asciidoctor::Diagrams::DitaaBlock
end
