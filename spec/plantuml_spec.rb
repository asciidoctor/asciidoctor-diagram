require_relative 'test_helper'

code = <<-eos
User -> (Start)
User --> (Use the application) : Label

:Main Admin: ---> (Use the application) : Another label
eos

describe Asciidoctor::Diagram::PlantUmlBlockMacroProcessor do
  include_examples "block_macro", :plantuml, code, [:png, :svg, :txt]

  it 'should support substitutions in diagram code' do
    code = <<-eos
class {parent-class}
class {child-class}
{parent-class} <|-- {child-class}
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:parent-class: ParentClass
:child-class: ChildClass

== First Section

plantuml::plantuml.txt[format="svg", subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to include('ParentClass')
    expect(content).to include('ChildClass')
  end

  it 'should support substitutions in the target attribute' do
    code = <<-eos
class {parent-class}
class {child-class}
{parent-class} <|-- {child-class}
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:file: plantuml
:parent-class: ParentClass
:child-class: ChildClass

== First Section

plantuml::{file}.txt[format="svg", subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to include('ParentClass')
    expect(content).to include('ChildClass')
  end

  it 'should support substitutions in the format attribute' do
    code = <<-eos
class Parent
class Child
Parent <|-- Child
    eos

    File.write('plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:file: plantuml
:plantumlformat: png

== First Section

plantuml::{file}.txt[format="{plantumlformat}", subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(target).to match(/\.png$/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it 'should resolve !include directives with relative paths' do
    included = <<-eos
interface List
List : int size()
List : void clear()
    eos

    code = <<-eos
!include list.iuml
List <|.. ArrayList
    eos

    Dir.mkdir('dir')
    File.write('dir/list.iuml', included)
    File.write('dir/plantuml.txt', code)

    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:parent-class: ParentClass
:child-class: ChildClass

== First Section

plantuml::dir/plantuml.txt[format="svg", subs=attributes+]
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}

    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to_not include('!include')
  end
end

describe Asciidoctor::Diagram::PlantUmlBlockProcessor do
  include_examples "block", :plantuml, code, [:png, :svg, :txt]

  it 'should use plantuml configuration when specified as a document attribute' do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>
:plantuml-config: test.config
:plantuml-format: svg

== First Section

[plantuml]
----
actor Foo1
boundary Foo2
Foo1 -> Foo2 : To boundary
----
    eos

    config = <<-eos
skinparam ArrowColor #DEADBE
    eos

    File.open('test.config', 'w') do |f|
      f.write config
    end

    d = load_asciidoc doc
    b = d.find { |bl| bl.context == :image }

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(File.exist?(target)).to be true

    svg = File.read(target, :encoding => Encoding::UTF_8)
    expect(svg).to match(/<[^<]+ fill=["']#DEADBE["']/)
  end

  it 'should support salt diagrams using salt block type' do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[salt, format="png"]
----
{
  Just plain text
  [This is my button]
  ()  Unchecked radio
  (X) Checked radio
  []  Unchecked box
  [X] Checked box
  "Enter text here   "
  ^This is a droplist^
}
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

  it 'should support salt diagrams using plantuml block type' do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="png"]
----
salt
{
  Just plain text
  [This is my button]
  ()  Unchecked radio
  (X) Checked radio
  []  Unchecked box
  [X] Checked box
  "Enter text here   "
  ^This is a droplist^
}
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

  it 'should support salt diagrams containing tree widgets' do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="png"]
----
salt
{
{T
+A
++a
}
}
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

  it 'should handle embedded creole images correctly' do
    creole_doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="png"]
----
:* You can change <color:red>text color</color>
* You can change <back:cadetblue>background color</back>
* You can change <size:18>size</size>
* You use <u>legacy</u> <b>HTML <i>tag</i></b>
* You use <u:red>color</u> <s:green>in HTML</s> <w:#0000FF>tag</w>
* Use image : <img:sourceforge.jpg>
* Use image : <img:http://www.foo.bar/sourceforge.jpg>
* Use image : <img:file:///sourceforge.jpg>

;
----
    eos

    load_asciidoc creole_doc, :attributes => {'backend' => 'html5'}

    # No real way to assert this since PlantUML doesn't produce an error on file not found
  end

  it 'should resolve !include directives with relative paths' do
    included = <<-eos
interface List
List : int size()
List : void clear()
    eos

    sub = <<-eos
@startuml
A -> A : stuff1
!startsub BASIC
B -> B : stuff2
!endsub
C -> C : stuff3
!startsub BASIC
D -> D : stuff4
!endsub
@enduml
    eos

    Dir.mkdir('dir')
    File.write('dir/List.iuml', included)
    File.write('dir/Sub.iuml', sub)

    creole_doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="svg"]
----
!include dir/List.iuml
!includesub dir/Sub.iuml!BASIC
List <|.. ArrayList
----
    eos

    d = load_asciidoc creole_doc, :attributes => {'backend' => 'html5'}

    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to_not include('!include')
    expect(content).to_not include('!includesub')
  end

  it 'should not resolve stdlib !include directives' do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml, format="svg"]
----
@startuml
!include <tupadr3/common>
!include <tupadr3/font-awesome/server>
!include <tupadr3/font-awesome/database>

title Styling example

FA_SERVER(web1,web1) #Green
FA_SERVER(web2,web2) #Yellow
FA_SERVER(web3,web3) #Blue
FA_SERVER(web4,web4) #YellowGreen

FA_DATABASE(db1,LIVE,database,white) #RoyalBlue
FA_DATABASE(db2,SPARE,database) #Red

db1 <--> db2

web1 <--> db1
web2 <--> db1
web3 <--> db1
web4 <--> db1
@enduml
----
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}

    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to_not include('!include')
  end

  it 'should support substitutions' do
    doc = <<-eos
= Hello, PlantUML!
:parent-class: ParentClass
:child-class: ChildClass

[plantuml,class-inheritence,svg,subs=attributes+]
....
class {parent-class}
class {child-class}
{parent-class} <|-- {child-class}
....
    eos

    d = load_asciidoc doc, :attributes => {'backend' => 'html5'}
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    target = b.attributes['target']
    expect(File.exist?(target)).to be true

    content = File.read(target, :encoding => Encoding::UTF_8)
    expect(content).to include('ParentClass')
    expect(content).to include('ChildClass')
  end

  it "should generate PNG images for jlatexmath blocks when format is set to 'png'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml,format="png"]
----
@startlatex
e^{i\\pi} + 1 = 0
@endlatex
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

  it "should generate SVG images for jlatexmath blocks when format is set to 'svg'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml,format="svg"]
----
@startlatex
e^{i\\pi} + 1 = 0
@endlatex
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
  end

  it "should generate PNG images for diagrams with latex tags when format is set to 'png'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml,format="png"]
----
:<latex>P(y|\\mathbf{x}) \\mbox{ or } f(\\mathbf{x})+\\epsilon</latex>;
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

  it "should generate SVG images for diagrams with latex tags when format is set to 'svg'" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml,format="svg"]
----
:<latex>P(y|\\mathbf{x}) \\mbox{ or } f(\\mathbf{x})+\\epsilon</latex>;
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

  it "should report syntax errors" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[plantuml,format="svg"]
----
Bob; Alice; foo
----
    eos

    expect {
      load_asciidoc doc
    }.to raise_error(/syntax error/i)
  end
end
