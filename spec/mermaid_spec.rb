require_relative 'test_helper'

code = <<-eos
graph LR
    A[Square Rect] -- Link text --> B((Circle))
    A --> C(Round Rect)
    B --> D{Rhombus}
    C --> D
eos

describe Asciidoctor::Diagram::MermaidBlockMacroProcessor do
  it "should generate PNG images when format is set to 'png'" do
    File.write('mermaid.txt', code)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[format="png"]
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
    File.write('mermaid.txt', code)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[format="svg"]
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
end

describe Asciidoctor::Diagram::MermaidBlockProcessor do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

[mermaid, format="png"]
----
#{code}
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
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

[mermaid, format="svg"]
----
#{code}
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

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

[mermaid, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end

  it "should not regenerate images when source has not changed" do
    File.write('mermaid.txt', code)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt

[mermaid, format="png"]
----
#{code}
----
    eos

    d = Asciidoctor.load StringIO.new(doc)
    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    mtime1 = File.mtime(target)

    sleep 1

    d = Asciidoctor.load StringIO.new(doc)

    mtime2 = File.mtime(target)

    expect(mtime2).to eq mtime1
  end

  it "should handle two block macros with the same source" do
    File.write('mermaid.txt', code)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[]
mermaid::mermaid.txt[]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('mermaid.png')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('mermaid.txt', code)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt["foobar"]
mermaid::mermaid.txt["foobaz"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('foobar.png')).to be true
    expect(File.exists?('foobaz.png')).to be true
    expect(File.exists?('mermaid.png')).to be false
  end

  it "should respect the sequenceConfig attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    eos

    seq_config = <<-eos
{
  "diagramMarginX": 0,
  "diagramMarginY": 0,
  "actorMargin": 0,
  "boxMargin": 0,
  "boxTextMargin": 0,
  "noteMargin": 0,
  "messageMargin": 0
}
    eos
    File.write('seqconfig.txt', seq_config)

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt["with_config", sequenceConfig="seqconfig.txt"]
mermaid::mermaid.txt["without_config"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('with_config.png')).to be true
    expect(File.exists?('without_config.png')).to be true
    expect(File.size('with_config.png')).to_not be File.size('without_config.png')
  end

  it "should respect the width attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    eos

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt["with_width", width="700"]
mermaid::mermaid.txt["without_width"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('with_width.png')).to be true
    expect(File.exists?('without_width.png')).to be true
    expect(File.size('with_width.png')).to_not be File.size('without_width.png')
  end
end