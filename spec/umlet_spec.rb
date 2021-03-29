require_relative 'test_helper'

CODE = <<-eos
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<diagram program="umlet" version="14.2">
  <zoom_level>10</zoom_level>
  <element>
    <id>UMLActor</id>
    <coordinates>
      <x>20</x>
      <y>20</y>
      <w>60</w>
      <h>120</h>
    </coordinates>
    <panel_attributes>Hello
AsciiDoc</panel_attributes>
    <additional_attributes/>
  </element>
</diagram>
eos


describe Asciidoctor::Diagram::UmletBlockMacroProcessor do
  include_examples "block_macro", :umlet, CODE, [:svg]
end

describe Asciidoctor::Diagram::UmletBlockProcessor do
  include_examples "block", :umlet, CODE, [:svg]
end
