require_relative 'test_helper'

code = <<-eos
[Pirate|eyeCount: Int|raid();pillage()|
  [beard]--[parrot]
  [beard]-:>[foul mouth]
]

[<abstract>Marauder]<:--[Pirate]
[Pirate]- 0..7[mischief]
[jollyness]->[Pirate]
[jollyness]->[rum]
[jollyness]->[singing]
[Pirate]-> *[rum|tastiness: Int|swig()]
[Pirate]->[singing]
[singing]<->[rum]

[<start>st]->[<state>plunder]
[plunder]->[<choice>more loot]
[more loot]->[st]
[more loot] no ->[<end>e]

[<actor>Sailor] - [<usecase>shiver me;timbers]
eos

describe Asciidoctor::Diagram::NomnomlBlockMacroProcessor do
  it "should generate SVG images when format is set to 'svg'" do
    File.write('nomnoml.txt', code)

    doc = <<-eos
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

nomnoml::nomnoml.txt[format="svg"]
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

describe Asciidoctor::Diagram::NomnomlBlockProcessor, :broken_on_windows do
  it "should generate SVG images when format is set to 'svg'" do
    doc = <<-eos
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

[nomnoml, format="svg"]
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
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

[nomnoml, format="foobar"]
----
----
    eos

    expect { load_asciidoc doc }.to raise_error(/support.*format/i)
  end

  it "should not regenerate images when source has not changed" do
    File.write('nomnoml.txt', code)

    doc = <<-eos
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

nomnoml::nomnoml.txt

[nomnoml, format="svg"]
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
    File.write('nomnoml.txt', code)

    doc = <<-eos
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

nomnoml::nomnoml.txt[]
nomnoml::nomnoml.txt[]
    eos

    load_asciidoc doc
    expect(File.exist?('nomnoml.svg')).to be true
  end

  it "should respect target attribute in block macros" do
    File.write('nomnoml.txt', code)

    doc = <<-eos
= Hello, Nomnoml!
Doc Writer <doc@example.com>

== First Section

nomnoml::nomnoml.txt["foobar"]
nomnoml::nomnoml.txt["foobaz"]
    eos

    load_asciidoc doc
    expect(File.exist?('foobar.svg')).to be true
    expect(File.exist?('foobaz.svg')).to be true
    expect(File.exist?('nomnoml.svg')).to be false
  end
end