require_relative 'test_helper_methods'

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
  :gs1_128 => '(FNC1)(SP)00(SP)12345678(SP)0000000001',
  :qrcode => 'http://github.com/',
  :upca => '12360105707',
}

describe Asciidoctor::Diagram::BarcodeBlockProcessor do
  BARCODES.each_pair do |type, code|
    it "should support #{type}" do
      doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

[#{type},test,png,xdim=1,margin=10,height=100,foreground=darkgray,background=azure]
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

  it "should support complex QR codes" do
    doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

[qrcode]
----
BEGIN:VCARD
VERSION:3.0
N:Doe;John;;;
FN:John Doe
ORG:Example.com Inc.;
TITLE:Imaginary test person
EMAIL;type=INTERNET;type=WORK;type=pref:johnDoe@example.org
TEL;type=WORK;type=pref:+1 617 555 1212
TEL;type=WORK:+1 (617) 555-1234
TEL;type=CELL:+1 781 555 1212
TEL;type=HOME:+1 202 555 1212
item1.ADR;type=WORK:;;2 Enterprise Avenue;Worktown;NY;01111;USA
item1.X-ABADR:us
item2.ADR;type=HOME;type=pref:;;3 Acacia Avenue;Hoemtown;MA;02222;USA
item2.X-ABADR:us
NOTE:John Doe has a long and varied history\, being documented on more police files that anyone else. Reports of his death are alas numerous.
item3.URL;type=pref:http\://www.example/com/doe
item3.X-ABLabel:_$!<HomePage>!$_
item4.URL:http\://www.example.com/Joe/foaf.df
item4.X-ABLabel:FOAF
item5.X-ABRELATEDNAMES;type=pref:Jane Doe
item5.X-ABLabel:_$!<Friend>!$_
CATEGORIES:Work,Test group
X-ABUID:5AD380FD-B2DE-4261-BA99-DE1D1DB52FBE\:ABPerson
END:VCARD
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
end

describe Asciidoctor::Diagram::BarcodeBlockMacroProcessor do
  BARCODES.each_pair do |type, code|
    it "should support #{type}" do
      doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

#{type}::#{code}[xdim=1,margin=10,height=100,foreground=darkgray,background=azure]
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
  end
end

describe Asciidoctor::Diagram::BarcodeInlineMacroProcessor do
  BARCODES.each_pair do |type, code|
    it "should support #{type}" do
      doc = <<-eos
= Hello, barby!
Doc Writer <doc@example.com>

== First Section

#{type}:#{code}[xdim=1,margin=10,height=100,foreground=darkgray,background=azure]
      eos

      d = load_asciidoc doc
      expect(d).to_not be_nil

      b = d.find { |bl| bl.context == :paragraph }
      expect(b).to_not be_nil

      output = b.convert
      img_match = /<img[^>]*>/.match(output)
      expect(img_match).to_not be_nil
      img = img_match.to_s

      src_match = /src="([^"]*)"/.match(img)
      expect(src_match).to_not be_nil
      src = src_match[1]

      expect(src).to_not be_nil
      expect(src).to match(/\.svg$/)
      expect(File.exist?(src)).to be true

      expect(/width="([^"]*)"/.match(img)).to_not be_nil
      expect(/height="([^"]*)"/.match(img)).to_not be_nil
    end
  end
end