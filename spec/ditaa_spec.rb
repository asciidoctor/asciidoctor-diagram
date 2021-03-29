require_relative 'test_helper'

DITAA_CODE = <<-eos
+--------+   +-------+    +-------+
|        | --+ ditaa +--> |       |
|  Text  |   +-------+    |diagram|
|Document|   |!magic!|    |       |
|     {d}|   |       |    |       |
+---+----+   +-------+    +-------+
    :                         ^
    |       Lots of work      |
    +-------------------------+
eos

describe Asciidoctor::Diagram::DitaaBlockMacroProcessor do
  include_examples "block_macro", :ditaa, DITAA_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::DitaaBlockProcessor do
  include_examples "block", :ditaa, DITAA_CODE, [:png, :svg]

  it "should support ditaa options as attributes" do
    doc = <<-eos
:ditaa-option-antialias: false
:ditaa-option-round-corners: true
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[ditaa, shadows=false, separation=false, round-corners=false, scale=2.3]
----
+--------+   +-------+    +-------+
|        | --+ ditaa +--> |       |
|  Text  |   +-------+    |diagram|
|Document|   |!magic!|    |       |
|     {d}|   |       |    |       |
+---+----+   +-------+    +-------+
    :                         ^
    |       Lots of work      |
    +-------------------------+
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    expect(target).to match(/\.png$/)
    expect(File.exist?(target)).to be true
  end

  it "should regenerate images when options change" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[ditaa, test, png, {opts}]
----
+--------+   +-------+    +-------+
|        | --+ ditaa +--> |       |
|  Text  |   +-------+    |diagram|
|Document|   |!magic!|    |       |
|     {d}|   |       |    |       |
+---+----+   +-------+    +-------+
    :                         ^
    |       Lots of work      |
    +-------------------------+
----
    eos

    d = load_asciidoc(doc.sub('{opts}', 'shadow=false'))
    b = d.find { |bl| bl.context == :image }
    target = b.attributes['target']
    mtime1 = File.mtime(target)

    sleep 1

    d = load_asciidoc(doc.sub('{opts}', 'round-corners=true'))

    mtime2 = File.mtime(target)

    expect(mtime2).to be > mtime1
  end

  it "should support UTF-8 characters" do
    doc = <<-eos
= Test

[ditaa]
----
/-----\\
|\u00AB \u2026 \u00BB|
\\-----/
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.png$/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should report syntax errors" do
    doc = <<-eos
= Hello, Ditaa!
Doc Writer <doc@example.com>

== First Section

[ditaa,format="svg"]
----
This should cause a bug.

// TODO:
// - don't make bugs
// - oops I wrote a comment here

    +--------+   +-------+    +-------+
    |        | --+ ditaa +--> |       |
    |  Text  |   +-------+    |diagram|
    |Document|   |!magic!|    |       |
    |     {d}|   |       |    |       |
    +---+----+   +-------+    +-------+
        :                         ^
        |       Lots of work      |
        +-------------------------+
----
    eos

    expect {
      load_asciidoc doc
    }.to raise_error(/Ambiguous input/i)
  end
end