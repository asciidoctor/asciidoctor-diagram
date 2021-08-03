require_relative 'test_helper'

BARCODES = {
  :bookland => '978-0-306-40615-7',
  :codabar => 'A123456A',
  :code25 => '123456',
  :code25iata => '123456',
  :code25interleaved => '123456',
  :code39 => '123456',
  :code93 => '123456',
  :code128 => '123456',
  :code128a => '123456',
  :code128b => '123456',
  :code128c => '123456',
  :ean8 => '0170725',
  :ean13 => '070071967072',
  :gs1_128 => '[FNC1] 00 12345678 0000000001',
  # :pdf417 => '',
  :qr => 'http://github.com/',
  :upca => '12360105707',
}

describe Asciidoctor::Diagram::BarcodeBlockProcessor do
  BARCODES.each_pair do |type, code|
    it "should support #{type}" do
      doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

[barcode,test,png,#{type},xdim=1,margin=10,height=100,foreground=darkgray,background=azure]
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
      expect(target).to match(/\.png$/)
      expect(File.exist?(target)).to be true

      expect(b.attributes['width']).to_not be_nil
      expect(b.attributes['height']).to_not be_nil
    end
  end
end

describe Asciidoctor::Diagram::BarcodeBlockMacroProcessor do
  BARCODES.each_pair do |type, code|
    it "should support #{type}" do
      doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

barcode::#{type}[#{code},xdim=1,margin=10,height=100,foreground=darkgray,background=azure]
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
  end
end