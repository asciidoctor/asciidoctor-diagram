require_relative 'test_helper'

code = <<-eos
initial,
doing: entry/ write unit test
       do/ write code
       exit/ ...,
# smcat recognizes initial
# and final states by name
# and renders them appropriately
final;

initial      => "on backlog" : item adds most value;
"on backlog" => doing        : working on it;
doing        => testing      : built & unit tested;
testing      => "on backlog" : test not ok;
testing      => final        : test ok;
eos

describe Asciidoctor::Diagram::SmcatBlockMacroProcessor, :broken_on_windows do
  it "should generate SVG images when format is set to 'svg'" do
    File.write('smcat.txt', code)

    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

smcat::smcat.txt[format="svg"]
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.svg/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end
end

describe Asciidoctor::Diagram::SmcatBlockProcessor, :broken_on_windows do
  it "should generate SVG images when format is set to 'svg'" do
    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

[smcat, format="svg"]
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
    expect(target).to match(/\.svg/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

[smcat, format="foobar"]
----
----
    eos

    expect { load_asciidoc doc }.to raise_error(/support.*format/i)
  end

  it "should not regenerate images when source has not changed" do
    File.write('smcat.txt', code)

    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

smcat::smcat.txt

[smcat, format="svg"]
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
    File.write('smcat.txt', code)

    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

smcat::smcat.txt[]
smcat::smcat.txt[]
    eos

    load_asciidoc doc
    expect(File.exist?('smcat.svg')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('smcat.txt', code)

    doc = <<-eos
= Hello, Smcat!
Doc Writer <doc@example.com>

== First Section

smcat::smcat.txt["foobar"]
smcat::smcat.txt["foobaz"]
    eos

    load_asciidoc doc
    expect(File.exist?('foobar.svg')).to be true
    expect(File.exist?('foobaz.svg')).to be true
    expect(File.exist?('smcat.svg')).to be false
  end
end