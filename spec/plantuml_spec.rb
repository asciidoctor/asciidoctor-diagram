require_relative 'test_helper'

describe Asciidoctor::Diagram::PlantUmlBlock do
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

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
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

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end

  it "should use plantuml configuration when specified as a document attribute" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:plantumlconfig: test.config

== First Section

[plantuml, format="svg"]
----
actor Foo1
boundary Foo2
Foo1 -> Foo2 : To boundary
----
    eos

    config = <<-eos
ArrowColor #DEADBE
    eos

    File.open('test.config', 'w') do |f|
      f.write config
    end

    d = Asciidoctor.load StringIO.new(doc)
    b = d.find { |b| b.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exists?(target)).to be_true

    svg = File.read(target)
    expect(svg).to match /<path.*fill="#DEADBE"/
  end
end