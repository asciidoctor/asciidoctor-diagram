require_relative 'test_helper'

SMCAT_CODE = <<-eos
initial,
doing: entry/ write unit test
       do/ write code
       exit/ ...,
# smcat recognizes initial
# and final states by name
# and renders them appropriately
final;

initial      => "on backlog" : item adds most value;
"on backlog" => doing        : working on it;
doing        => testing      : built & unit tested;
testing      => "on backlog" : test not ok;
testing      => final        : test ok;
eos

describe Asciidoctor::Diagram::SmcatBlockMacroProcessor do
  include_examples "block_macro", :smcat, SMCAT_CODE, [:svg]
end

describe Asciidoctor::Diagram::SmcatBlockProcessor do
  include_examples "block", :smcat, SMCAT_CODE, [:svg]
end
