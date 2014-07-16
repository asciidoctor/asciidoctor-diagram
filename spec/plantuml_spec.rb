require_relative 'test_helper'

describe Asciidoctor::Diagram::PlantUmlBlockMacro do
  it "should generate PNG images when format is set to 'png'" do
    code = <<-eos
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

plantuml::plantuml.txt[format="png"]
    eos

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match /\.png$/
    expect(File.exists?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end
end

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
    expect(File.exists?(target)).to be true

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
    expect(File.exists?(target)).to be true

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

    expect(b.content_model).to eq :verbatim

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
    expect(File.exists?(target)).to be true

    svg = File.read(target)
    expect(svg).to match /<path.*fill="#DEADBE"/
  end

  it "should not regenerate images when source has not changed" do
    code = <<-eos
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

plantuml::plantuml.txt

[plantuml, format="png"]
----
actor Foo1
boundary Foo2
Foo1 -> Foo2 : To boundary
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    b = d.find { |b| b.context == :image }
    target = b.attributes['target']
    mtime1 = File.mtime(target)

    sleep 1

    d = Asciidoctor.load StringIO.new(doc)

    mtime2 = File.mtime(target)

    expect(mtime2).to eq mtime1
  end

  it "should handle two block macros with the same source" do
    code = <<-eos
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

plantuml::plantuml.txt[]
plantuml::plantuml.txt[]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('plantuml.png')).to be true
  end

  it "should respect target attribute in block macros" do
    code = <<-eos
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

plantuml::plantuml.txt["foobar"]
plantuml::plantuml.txt["foobaz"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('foobar.png')).to be true
    expect(File.exists?('foobaz.png')).to be true
    expect(File.exists?('plantuml.png')).to be false
  end


  it "should write files to outdir if set" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="svg"]
----
actor Foo1
boundary Foo2
Foo1 -> Foo2 : To boundary
----
    eos

    d = Asciidoctor.load StringIO.new(doc), {:attributes => {'outdir' => 'foo'}}
    b = d.find { |b| b.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exists?(target)).to be false
    expect(File.exists?(File.expand_path(target, 'foo'))).to be true
  end

  it "should omit width/height attributes when generating docbook" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="png"]
----
User -> (Start)
----
    eos

    d = Asciidoctor.load StringIO.new(doc), :attributes => {'backend' => 'docbook5' }
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exists?(target)).to be true

    expect(b.attributes['width']).to be_nil
    expect(b.attributes['height']).to be_nil
  end
end
