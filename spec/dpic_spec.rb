require_relative 'test_helper'

code = <<-eos
  arrow "$u$" above
S: circle rad 10/72.27  # 10 pt
  line right 0.35
G: box "$G(s)$"
  arrow "$y$" above
  line -> down G.ht from last arrow then left last arrow.c.x-S.x then to S.s
  "$-\;$" below rjust
eos

describe Asciidoctor::Diagram::DpicBlockMacroProcessor, :broken_on_travis, :broken_on_windows do
  it "should generate SVG images when format is set to 'svg'" do
    File.write('dpic.txt', code)

    doc = <<-eos
= Hello, Dpic!
Doc Writer <doc@example.com>

== First Section

dpic::dpic.txt[format="svg"]
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

describe Asciidoctor::Diagram::DpicBlockProcessor, :broken_on_travis, :broken_on_windows do
  it "should generate SVG images when format is set to 'svg'" do
    doc = <<-eos
= Hello, Dpic!
Doc Writer <doc@example.com>

== First Section

[dpic, format="svg"]
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
end