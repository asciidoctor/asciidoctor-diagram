require_relative 'test_helper_methods'

D2_CODE = <<-eos
# Actors
hans: Hans Niemann

defendants: {
  mc: Magnus Carlsen
  playmagnus: Play Magnus Group
  chesscom: Chess.com
  naka: Hikaru Nakamura

  mc -> playmagnus: Owns majority
  playmagnus <-> chesscom: Merger talks
  chesscom -> naka: Sponsoring
}

# Accusations
hans -> defendants: 'sueing for $100M'

# Offense
defendants.naka -> hans: Accused of cheating on his stream
defendants.mc -> hans: Lost then withdrew with accusations
defendants.chesscom -> hans: 72 page report of cheating
eos

describe Asciidoctor::Diagram::D2InlineMacroProcessor, :broken_on_windows do
  include_examples "inline_macro", :d2, D2_CODE, [:svg]
end

describe Asciidoctor::Diagram::D2BlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :d2, D2_CODE, [:svg]
end

describe Asciidoctor::Diagram::D2BlockProcessor, :broken_on_windows do
  include_examples "block", :d2, D2_CODE, [:svg]

  it "should not use sketch mode by default" do
    doc = <<-eos
= Hello, d2!
Doc Writer <doc@example.com>

== First Section

[d2]
----
#{D2_CODE}
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    expect(target).to match(/\.svg$/)
    expect(File.exist?(target)).to be true
    svg = File.read(target, :encoding => Encoding::UTF_8)
    expect(svg).to_not match(/class='.*?sketch-overlay-B5.*?'/)
  end

  it "should support sketch mode" do
    doc = <<-eos
= Hello, D2!
Doc Writer <doc@example.com>

== First Section

[d2, foobar, svg, sketch]
----
#{D2_CODE}
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    expect(target).to match(/\.svg$/)
    expect(File.exist?(target)).to be true
    svg = File.read(target, :encoding => Encoding::UTF_8)
    expect(svg).to match(/class='.*?sketch-overlay-B5.*?'/)
  end
end
