require_relative 'test_helper'

code = <<-eos
blockdiag {
   A -> B -> C -> D;
   A -> E -> F -> G;
}
eos

describe Asciidoctor::Diagram::BlockDiagBlockMacroProcessor do
  include_examples "block_macro", :blockdiag, code, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::BlockDiagBlockProcessor do
  include_examples "block", :blockdiag, code, [:png, :svg, :pdf]
end
