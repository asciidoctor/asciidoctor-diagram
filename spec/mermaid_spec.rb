require_relative 'test_helper'

MERMAID_CODE = <<-eos
graph LR
    A[Square Rect] -- Link text --> B((Circle))
    A --> C(Round Rect)
    B --> D{Rhombus}
    C --> D
eos

describe Asciidoctor::Diagram::MermaidBlockMacroProcessor do
  include_examples "block_macro", :mermaid, MERMAID_CODE, [:png, :svg]

  it "should respect the sequenceConfig attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    eos

    seq_config = <<-eos
{
  "diagramMarginX": 0,
  "diagramMarginY": 0,
  "actorMargin": 0,
  "boxMargin": 0,
  "boxTextMargin": 0,
  "noteMargin": 0,
  "messageMargin": 0
}
    eos
    File.write('seqconfig.txt', seq_config)

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[target="with_config", sequenceConfig="seqconfig.txt"]
mermaid::mermaid.txt[target="without_config"]
    eos

    load_asciidoc doc
    expect(File.exist?('with_config.png')).to be true
    expect(File.exist?('without_config.png')).to be true
    expect(File.size('with_config.png')).to_not be File.size('without_config.png')
  end

  it "should respect the width attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>Bob: Hello Bob, how are you?
    Bob->>Claire: Hello Claire, how are you?
    Claire->>Doug: Hello Doug, how are you?
    eos

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[target="with_width", width="700"]
mermaid::mermaid.txt[target="without_width"]
    eos

    load_asciidoc doc
    expect(File.exist?('with_width.png')).to be true
    expect(File.exist?('without_width.png')).to be true
    expect(File.size('with_width.png')).to_not be File.size('without_width.png')
  end

  it "should respect the theme attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>Bob: Hello Bob, how are you?
    Bob->>Claire: Hello Claire, how are you?
    Claire->>Doug: Hello Doug, how are you?
    eos

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[target="default", format="svg"]
mermaid::mermaid.txt[target="dark", format="svg", theme="dark"]
    eos

    load_asciidoc doc
    expect(File.exist?('default.svg')).to be true
    expect(File.exist?('dark.svg')).to be true
    expect(File.read('default.svg')).to_not be File.read('dark.svg')
  end

  it "should respect the puppeteerConfig attribute" do
    seq_diag = <<-eos
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
    eos

    pptr_config = <<-eos
{
    "args": ["--no-sandbox"]
}
    eos
    File.write('pptrconfig.txt', pptr_config)

    File.write('mermaid.txt', seq_diag)

    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

mermaid::mermaid.txt[target="with_config", puppeteerConfig="pptrconfig.txt"]
mermaid::mermaid.txt[target="without_config"]
    eos

    load_asciidoc doc
    expect(File.exist?('with_config.png')).to be true
    expect(File.exist?('without_config.png')).to be true
    expect(File.size('with_config.png')).to be File.size('without_config.png')
  end
end

describe Asciidoctor::Diagram::MermaidBlockProcessor do
  include_examples "block", :mermaid, MERMAID_CODE, [:png, :svg]

  it "should work with kroki.io" do
    doc = <<-eos
= Hello, kroki!
:diagram-server-url: https://kroki.io/
:diagram-server-type: kroki_io
Doc Writer <doc@example.com>

== First Section

[mermaid, format=svg]
----
graph TD
  A[ Anyone ] -->|Can help | B( Go to github.com/yuzutech/kroki )
  B --> C{ How to contribute? }
  C --> D[ Reporting bugs ]
  C --> E[ Sharing ideas ]
  C --> F[ Advocating ]
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.svg$/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should report unsupported scaling factors" do
    doc = <<-eos
= Hello, Mermaid!
Doc Writer <doc@example.com>

== First Section

[mermaid, scale=1.5]
----
sequenceDiagram
    Alice->>John: Hello John, how are you?
    John-->>Alice: Great!
----
    eos

    expect { load_asciidoc doc }.to raise_error(/support.*scale/i)
  end
end
