require_relative 'test_helper'

CODE = <<-eos
digraph foo {
  node [style=rounded]
  node1 [shape=box]
  node2 [fillcolor=yellow, style="rounded,filled", shape=diamond]
  node3 [shape=record, label=" a b c"]

  node1 -> node2 -> node3
}
eos

describe Asciidoctor::Diagram::GraphvizBlockMacroProcessor do
  include_examples "block_macro", :graphviz, CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::GraphvizBlockProcessor do
  include_examples "block", :graphviz, CODE, [:png, :svg]
end