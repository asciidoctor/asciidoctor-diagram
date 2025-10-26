require_relative 'test_helper_methods'

Oxdraw_CODE = <<-eos
graph TD
    sub[[Subroutine]] --> cyl[(Database)]
    cyl --> hex{{Prepare}}
    hex --> stop(((Stop)))

%% Oxdraw LAYOUT START
%% {
%%   "nodes": {
%%     "cyl": {
%%       "x": 60.0,
%%       "y": 310.0
%%     },
%%     "hex": {
%%       "x": 265.0,
%%       "y": 310.0
%%     },
%%     "sub": {
%%       "x": 60.0,
%%       "y": 210.0
%%     },
%%     "stop": {
%%       "x": 265.0,
%%       "y": 400.0
%%     }
%%   },
%%   "edges": {},
%%   "node_styles": {},
%%   "edge_styles": {}
%% }
%% Oxdraw LAYOUT END
eos

describe Asciidoctor::Diagram::OxdrawInlineMacroProcessor do
  include_examples "inline_macro", :oxdraw, Oxdraw_CODE, [:svg, :png]
end

describe Asciidoctor::Diagram::OxdrawBlockMacroProcessor do
  include_examples "block_macro", :oxdraw, Oxdraw_CODE, [:svg, :png]
end

describe Asciidoctor::Diagram::OxdrawBlockProcessor do
  include_examples "block", :oxdraw, Oxdraw_CODE, [:svg, :png]
end
