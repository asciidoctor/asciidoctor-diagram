require_relative 'test_helper'

RSpec.shared_examples "block_macro" do |name, code, formats|
  formats.each do |format|
    if format == :txt
      it "#{name} should generate literal blocks when format is set to 'txt'" do
        File.write("#{name}.txt", code)

        doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

#{name}::#{name}.txt[#{format}]
        eos

        d = load_asciidoc doc
        expect(d).to_not be_nil

        b = d.find { |bl| bl.context == :literal }
        expect(b).to_not be_nil

        expect(b.content_model).to eq :verbatim

        expect(b.attributes['target']).to be_nil
      end
    else
      it "#{name} should generate image blocks when format is set to '#{format}'" do
        File.write("#{name}.txt", code)

        doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

#{name}::#{name}.txt[#{format}]
        eos

        d = load_asciidoc doc
        expect(d).to_not be_nil

        b = d.find { |bl| bl.context == :image }
        expect(b).to_not be_nil

        expect(b.content_model).to eq :empty

        target = b.attributes['target']
        expect(target).to_not be_nil
        expect(target).to match(/\.#{format}$/)
        expect(File.exist?(target)).to be true

        unless format == :pdf
          expect(b.attributes['width']).to_not be_nil
          expect(b.attributes['height']).to_not be_nil
        end
      end
    end
  end

  it 'should support substitutions in the target attribute' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>
:file: #{name}

== First Section

#{name}::{file}.txt[subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true
  end

  it 'should support substitutions in the format attribute' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>
:file: #{name}
:outputformat: #{formats[0]}

== First Section

#{name}::{file}.txt[format="{outputformat}", subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(target).to match(/\.#{formats[0]}$/)
    expect(File.exist?(target)).to be true

    unless formats[0] == :pdf
      expect(b.attributes['width']).to_not be_nil
      expect(b.attributes['height']).to_not be_nil
    end
  end

  it 'should generate blocks with figure captions' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

.This is a diagram
#{name}::#{name}.txt[]
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.caption).to match(/Figure \d+/)
  end

  it 'should handle two block macros with the same source' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

#{name}::#{name}.txt[]
#{name}::#{name}.txt[]
    eos

    d = load_asciidoc doc

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true
  end

  it 'should respect target attribute in block macros' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

#{name}::#{name}.txt[target="foobar"]
#{name}::#{name}.txt[target="foobaz"]
    eos

    load_asciidoc doc
    expect(File.exist?("foobar.#{formats[0]}")).to be true
    expect(File.exist?("foobaz.#{formats[0]}")).to be true
    expect(File.exist?("#{name}.#{formats[0]}")).to be false
  end

  it 'should respect target attribute values with relative paths in block macros' do
    File.write("#{name}.txt", code)

    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

#{name}::#{name}.txt[target="test/foobar"]
#{name}::#{name}.txt[target="test2/foobaz"]
    eos

    load_asciidoc doc
    expect(File.exist?("test/foobar.#{formats[0]}")).to be true
    expect(File.exist?("test2/foobaz.#{formats[0]}")).to be true
    expect(File.exist?("#{name}.#{formats[0]}")).to be false
  end
end

RSpec.shared_examples "block" do |name, code, formats|
  formats.each do |format|
    if format == :txt
      it "#{name} should generate literal blocks when format is set to 'txt'" do
        doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, format="#{format}"]
----
#{code}
----
        eos

        d = load_asciidoc doc
        expect(d).to_not be_nil

        b = d.find { |bl| bl.context == :literal }
        expect(b).to_not be_nil

        expect(b.content_model).to eq :verbatim

        expect(b.attributes['target']).to be_nil
      end
    else
      it "#{name} should generate image blocks when format is set to '#{format}'" do
        doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, format="#{format}"]
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
        expect(target).to match(/\.#{format}$/)
        expect(File.exist?(target)).to be true

        unless format == :pdf
          expect(b.attributes['width']).to_not be_nil
          expect(b.attributes['height']).to_not be_nil
        end
      end
    end
  end

  if formats.include? :svg
    it "#{name} should respect the svg-type attribute when format is set to 'svg'" do
      doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, format="svg", svg-type="inline"]
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

      expect(b.option?('inline')).to be_truthy

      unless formats[0] == :pdf
        expect(b.attributes['width']).to_not be_nil
        expect(b.attributes['height']).to_not be_nil
      end
    end

    it "#{name} should respect the diagram-svg-type attribute when format is set to 'svg'" do
      doc = <<-eos
= Hello, #{name}!
:diagram-svg-type: inline
Doc Writer <doc@example.com>

== First Section

[#{name}, format="svg"]
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

      expect(b.option?('inline')).to be_truthy

      unless formats[0] == :pdf
        expect(b.attributes['width']).to_not be_nil
        expect(b.attributes['height']).to_not be_nil
      end
    end
  end

  it 'should raise an error when when format is set to an invalid value' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, format="foobar"]
----
----
    eos

    expect { load_asciidoc doc }.to raise_error(/support.*format/i)
  end

  it 'should not regenerate images when source has not changed' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc
    b1 = d.find { |bl| bl.context == :image }
    target1 = b1.attributes['target']
    mtime1 = File.mtime(target1)

    sleep 1

    d = load_asciidoc doc
    b2 = d.find { |bl| bl.context == :image }
    target2 = b2.attributes['target']

    mtime2 = File.mtime(target1)

    expect(mtime2).to eq mtime1
  end

  it 'should write files to outdir if set' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc, {:attributes => {'outdir' => 'foo'}}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, 'foo'))).to be true
  end

  it 'should write files to to_dir if set' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc, {:to_dir => 'foo'}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, 'foo'))).to be true
  end

  it 'should write files to to_dir if set in safe mode' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    to_dir = File.expand_path('foo')
    d = load_asciidoc doc, {:to_dir => to_dir, :safe => :safe}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, to_dir))).to be true
  end

  it 'should write files to to_dir if set when embedded in table' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

|===
|Type | Example

|graphviz
a|
[#{name}]
----
#{code.gsub('|', '\|')}
----
|===
    eos

    d = load_asciidoc doc, {:to_dir => 'foo'}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, 'foo'))).to be true
  end

  it 'should write files to imagesoutdir if set' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc, {:attributes => {'imagesoutdir' => 'bar', 'outdir' => 'foo'}}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, 'bar'))).to be true
    expect(File.exist?(File.expand_path(target, 'foo'))).to be false
  end

  it 'should write files to imagesoutdir if set in safe mode' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    out_dir = File.expand_path('foo')
    images_out_dir = File.expand_path('bar')

    d = load_asciidoc doc, {:attributes => {'imagesoutdir' => images_out_dir, 'outdir' => out_dir}, :safe => :safe}
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be false
    expect(File.exist?(File.expand_path(target, images_out_dir))).to be true
    expect(File.exist?(File.expand_path(target, out_dir))).to be false
  end

  it 'should omit width/height attributes when generating docbook' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'docbook5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to be_nil
    expect(b.attributes['height']).to be_nil
  end

  it 'should generate blocks with figure captions' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

.Caption for my diagram
[#{name}]
----
#{code}
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.caption).to match(/Figure \d+/)
  end

  it 'should support scaling diagrams' do
    doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, target="unscaled"]
----
#{code}
----
    eos

    scaled_doc = <<-eos
= Hello, #{name}!
Doc Writer <doc@example.com>

== First Section

[#{name}, scale="2", target="scaled"]
----
#{code}
----
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    unscaled_image = d.find { |bl| bl.context == :image }

    d = load_asciidoc scaled_doc, :attributes => {'backend' => 'html5'}
    scaled_image = d.find { |bl| bl.context == :image }

    unless formats[0] == :pdf
      expect(scaled_image.attributes['width']).to be_within(1).of(unscaled_image.attributes['width'] * 2)
      expect(scaled_image.attributes['height']).to be_within(1).of(unscaled_image.attributes['height'] * 2)
    end
  end
end
