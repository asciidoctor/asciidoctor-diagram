require_relative 'test_helper_methods'

VHS_CODE = <<-eos
Set FontSize 14
Set Width 600
Set Height 400

Type "echo Hello World"
Enter
Sleep 500ms
eos

describe Asciidoctor::Diagram::VhsInlineMacroProcessor do
  include_examples "inline_macro", :tape, VHS_CODE, [:svg, :gif]
end

describe Asciidoctor::Diagram::VhsBlockMacroProcessor do
  include_examples "block_macro", :tape, VHS_CODE, [:svg, :gif]
end

describe Asciidoctor::Diagram::VhsBlockProcessor do
  include_examples "block", :tape, VHS_CODE, [:svg, :gif]
end

