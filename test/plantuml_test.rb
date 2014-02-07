require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/cli/invoker'
require 'stringio'

describe Asciidoctor::PlantUml::Block do

  it "version must be defined" do
    Asciidoctor::PlantUml::VERSION.wont_be_nil
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

    doc = Asciidoctor.load StringIO.new(doc)
  end
end