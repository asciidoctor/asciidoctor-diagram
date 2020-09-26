require_relative 'test_helper'

code = <<-eos
blockdiag {
   A -> B -> C -> D;
   A -> E -> F -> G;
}
eos

describe Asciidoctor::Diagram::BlockDiagBlockMacroProcessor, :broken_on_appveyor do
  include_examples "block_macro", :blockdiag, code, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::BlockDiagBlockProcessor, :broken_on_appveyor do
  include_examples "block", :blockdiag, code, [:png, :svg, :pdf]
end