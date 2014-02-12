require_relative 'test_helper'

describe Asciidoctor::Diagrams::DitaaBlock do
  it "should generate PNG images when format is set to 'png'" do
    doc = <<-eos
= Hello, ditaa!
Doc Writer <doc@example.com>

== First Section

[ditaa, format="png"]
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

    d = Asciidoctor.load StringIO.new(doc)
    expect(d).to_not be_nil

    b = d.find { |b| b.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match /\.png$/
    expect(File.exists?(target)).to be_true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should raise an error when when format is set to an invalid value" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[ditaa, format="foobar"]
----
----
    eos

    expect { Asciidoctor.load StringIO.new(doc) }.to raise_error /support.*format/i
  end
end