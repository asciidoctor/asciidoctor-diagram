require_relative 'test_helper'

describe Asciidoctor::Diagram::BpmnBlockMacroProcessor do
  it "should generate SVG images when format is set to 'svg'" do
    FileUtils.cp(
        File.expand_path('bpmn-example.xml', File.dirname(__FILE__)),
        File.expand_path('bpmn-example.xml', Dir.getwd)
    )

    doc = <<-eos
= Hello, BPMN!
Doc Writer <doc@example.com>

== First Section

bpmn::bpmn-example.xml[format="svg"]
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

  it "should generate PNG images when format is set to 'png'" do
    FileUtils.cp(
        File.expand_path('bpmn-example.xml', File.dirname(__FILE__)),
        File.expand_path('bpmn-example.xml', Dir.getwd)
    )

    doc = <<-eos
= Hello, BPMN!
Doc Writer <doc@example.com>

== First Section

bpmn::bpmn-example.xml[format="png"]
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

  it "should generate PDF images when format is set to 'pdf'" do
    FileUtils.cp(
        File.expand_path('bpmn-example.xml', File.dirname(__FILE__)),
        File.expand_path('bpmn-example.xml', Dir.getwd)
    )

    doc = <<-eos
= Hello, BPMN!
Doc Writer <doc@example.com>

== First Section

bpmn::bpmn-example.xml[format="pdf"]
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.pdf$/)
    expect(File.exist?(target)).to be true
  end
end
