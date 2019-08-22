require_relative 'test_helper'

code = <<-eos
\\relative c' { f d f a d f e d cis a cis e a g f e }
eos

describe Asciidoctor::Diagram::LilypondBlockMacroProcessor, :broken_on_windows do
  it "should generate PNG images when format is set to 'png'" do
    File.write('lilypond.txt', code)

    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

lilypond::lilypond.txt[format="png"]
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.png/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end
end

describe Asciidoctor::Diagram::LilypondBlockProcessor, :broken_on_windows do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

[lilypond, format="png"]
----
#{code}
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.png/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

[lilypond, format="foobar"]
----
----
    eos

    expect { load_asciidoc doc }.to raise_error(/support.*format/i)
  end

  it "should not regenerate images when source has not changed" do
    File.write('lilypond.txt', code)

    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

lilypond::lilypond.txt

[lilypond, format="png"]
----
#{code}
----
    eos

    d = load_asciidoc doc
    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    mtime1 = File.mtime(target)

    sleep 1

    d = load_asciidoc doc

    mtime2 = File.mtime(target)

    expect(mtime2).to eq mtime1
  end

  it "should handle two block macros with the same source" do
    File.write('lilypond.txt', code)

    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

lilypond::lilypond.txt[]
lilypond::lilypond.txt[]
    eos

    load_asciidoc doc
    expect(File.exist?('lilypond.png')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('lilypond.txt', code)

    doc = <<-eos
= Hello, Lilypond!
Doc Writer <doc@example.com>

== First Section

lilypond::lilypond.txt["foobar"]
lilypond::lilypond.txt["foobaz"]
    eos

    load_asciidoc doc
    expect(File.exist?('foobar.png')).to be true
    expect(File.exist?('foobaz.png')).to be true
    expect(File.exist?('lilypond.png')).to be false
  end
end