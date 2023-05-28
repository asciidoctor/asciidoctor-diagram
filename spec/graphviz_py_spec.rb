require_relative 'test_helper_methods'

GRAPHVIZ_PY_CODE = <<-eos
graph python_graph {
{{
import math

value = 0.5
sin = math.sin(value)
cos = math.cos(value)
}}

A [label="{{= value }}"];
B [label="{{= sin }}"];
C [label="{{= cos }}"];

A -- B [headlabel="sin"];
A -- C [headlabel="cos"];

}
eos

describe Asciidoctor::Diagram::GraphvizPyInlineMacroProcessor, :broken_on_github do
  include_examples "inline_macro", :graphviz_py, GRAPHVIZ_PY_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::GraphvizPyBlockMacroProcessor, :broken_on_github do
  include_examples "block_macro", :graphviz_py, GRAPHVIZ_PY_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::GraphvizPyBlockProcessor, :broken_on_github do
  include_examples "block", :graphviz_py, GRAPHVIZ_PY_CODE, [:png, :svg]
end
