require_relative 'test_helper_methods'

BLOCKDIAG_CODE = <<-eos
blockdiag {
   A -> B -> C -> D;
   A -> E -> F -> G;
}
eos

describe Asciidoctor::Diagram::BlockDiagInlineMacroProcessor do
  include_examples "inline_macro", :blockdiag, BLOCKDIAG_CODE, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::BlockDiagBlockMacroProcessor do
  include_examples "block_macro", :blockdiag, BLOCKDIAG_CODE, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::BlockDiagBlockProcessor do
  include_examples "block", :blockdiag, BLOCKDIAG_CODE, [:png, :svg, :pdf]
end
