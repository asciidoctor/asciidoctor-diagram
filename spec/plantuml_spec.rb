require_relative 'test_helper'

require 'fileutils'
require 'stringio'
require 'tmpdir'

describe Asciidoctor::PlantUml::Block do
  it "version must be defined" do
    expect(Asciidoctor::PlantUml::VERSION).to_not be_nil
  end

  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="png"]
----
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match /\.png$/
    expect(File.exists?(target)).to be_true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should generate SVG images when format is set to 'svg'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="svg"]
----
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match /\.svg/
    expect(File.exists?(target)).to be_true
  end

  it "should generate literal blocks when format is set to 'txt'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="txt"]
----
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :literal }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :simple

    expect(b.attributes['target']).to be_nil
  end

  it "should generate literal blocks when format is set to 'utxt'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="utxt"]
----
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :literal }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :simple

    expect(b.attributes['target']).to be_nil
  end

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /unsupported.*format/i
  end
end