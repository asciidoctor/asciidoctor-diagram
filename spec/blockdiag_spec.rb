require_relative 'test_helper'

code = <<-eos
blockdiag {
   A -> B -> C -> D;
   A -> E -> F -> G;
}
eos

describe Asciidoctor::Diagram::BlockDiagBlockMacro do
  it "should generate PNG images when format is set to 'png'" do
    File.write('blockdiag.txt', code)

    doc = <<-eos
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

blockdiag::blockdiag.txt[format="png"]
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

describe Asciidoctor::Diagram::BlockDiagBlock do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

[blockdiag, format="png"]
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
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

[blockdiag, format="svg"]
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
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

[blockdiag, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end

  it "should not regenerate images when source has not changed" do
    File.write('blockdiag.txt', code)

    doc = <<-eos
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

blockdiag::blockdiag.txt

[blockdiag, format="png"]
----
#{code}
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
    File.write('blockdiag.txt', code)

    doc = <<-eos
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

blockdiag::blockdiag.txt[]
blockdiag::blockdiag.txt[]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('blockdiag.png')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('blockdiag.txt', code)

    doc = <<-eos
= Hello, BlockDiag!
Doc Writer <doc@example.com>

== First Section

blockdiag::blockdiag.txt["foobar"]
blockdiag::blockdiag.txt["foobaz"]
    eos

    Asciidoctor.load StringIO.new(doc)
    expect(File.exists?('foobar.png')).to be true
    expect(File.exists?('foobaz.png')).to be true
    expect(File.exists?('blockdiag.png')).to be false
  end
end