require_relative "test_helper_methods"

GOAT_CODE = <<-eos
.---.     .-.       .-.       .-.     .---.
| A +--->| 1 |<--->| 2 |<--->| 3 |<---+ B |
'---'     '-'       '+'       '+'     '---'
eos

describe Asciidoctor::Diagram::GoATInlineMacroProcessor do
  include_examples "inline_macro", :goat, GOAT_CODE, [:svg]
end

describe Asciidoctor::Diagram::GoATBlockMacroProcessor do
  include_examples "block_macro", :goat, GOAT_CODE, [:svg]
end

describe Asciidoctor::Diagram::GoATBlockProcessor do
  include_examples "block", :goat, GOAT_CODE, [:svg]
end
