require_relative 'test_helper'

code = <<-eos
{ signal : [
  { name: "clk",  wave: "p......" },
  { name: "bus",  wave: "x.34.5x",   data: "head body tail" },
  { name: "wire", wave: "0.1..0." },
]}
eos

describe Asciidoctor::Diagram::WavedromBlockMacroProcessor, :broken => true do
  it "should generate PNG images when format is set to 'png'" do
    File.write('wavedrom.txt', code)

    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

wavedrom::wavedrom.txt[format="png"]
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
    File.write('wavedrom.txt', code)

    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

wavedrom::wavedrom.txt[format="svg"]
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

describe Asciidoctor::Diagram::WavedromBlockProcessor, :broken => true do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

[wavedrom, format="png"]
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
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

[wavedrom, format="svg"]
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
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

[wavedrom, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end

  it "should not regenerate images when source has not changed" do
    File.write('wavedrom.txt', code)

    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

wavedrom::wavedrom.txt

[wavedrom, format="png"]
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
    File.write('wavedrom.txt', code)

    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

wavedrom::wavedrom.txt[]
wavedrom::wavedrom.txt[]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('wavedrom.png')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('wavedrom.txt', code)

    doc = <<-eos
= Hello, Wavedrom!
Doc Writer <doc@example.com>

== First Section

wavedrom::wavedrom.txt["foobar"]
wavedrom::wavedrom.txt["foobaz"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('foobar.png')).to be true
    expect(File.exists?('foobaz.png')).to be true
    expect(File.exists?('wavedrom.png')).to be false
  end
end