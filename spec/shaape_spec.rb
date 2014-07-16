require_relative 'test_helper'

describe Asciidoctor::Diagram::ShaapeBlockMacro do
  it "should generate PNG images when format is set to 'png'" do
    code = <<-eos
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
    eos

    File.write('shaape.txt', code)

    doc = <<-eos
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

shaape::shaape.txt[format="png"]
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

describe Asciidoctor::Diagram::ShaapeBlock do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

[shaape, format="png"]
----
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
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
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

[shaape, format="svg"]
----
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
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
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

[shaape, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end

  it "should not regenerate images when source has not changed" do
    code = <<-eos
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
    eos

    File.write('shaape.txt', code)

    doc = <<-eos
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

shaape::shaape.txt

[shaape, format="png"]
----
    +--------+
    |        |
    | Hello  |
    |   ;)   |
    |        |
    +--------+
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
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
    eos

    File.write('shaape.txt', code)

    doc = <<-eos
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

shaape::shaape.txt[]
shaape::shaape.txt[]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('shaape.png')).to be true
  end

  it "should respect target attribute in block macros" do
    code = <<-eos
    +--------+    +-------------+
    |        |     \\           /
    | Hello  |--->  \\ Goodbye /
    |   ;)   |      /         \\
    |        |     /           \\
    +--------+    +-------------+
    eos

    File.write('shaape.txt', code)

    doc = <<-eos
= Hello, Shaape!
Doc Writer <doc@example.com>

== First Section

shaape::shaape.txt["foobar"]
shaape::shaape.txt["foobaz"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('foobar.png')).to be true
    expect(File.exists?('foobaz.png')).to be true
    expect(File.exists?('shaape.png')).to be false
  end
end