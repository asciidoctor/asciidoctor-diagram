require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/cli/invoker'
require 'stringio'

describe Asciidoctor::PlantUML::PlantUMLBlock do

  it "version must be defined" do
    Asciidoctor::PlantUML::VERSION.wont_be_nil
  end

  it "should process basic plantuml blocks" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

An introduction to http://asciidoc.org[AsciiDoc].

== First Section

[plantuml, format="svg"]
----
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
----
    eos

    result = Asciidoctor.render StringIO.new(doc)
    puts result
  end
end