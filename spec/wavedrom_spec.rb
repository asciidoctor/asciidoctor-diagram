require_relative 'test_helper'

code = <<-eos
{ signal : [
  { name: "clk",  wave: "p......" },
  { name: "bus",  wave: "x.34.5x",   data: "head body tail" },
  { name: "wire", wave: "0.1..0." },
]}
eos

describe Asciidoctor::Diagram::WavedromBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :wavedrom, code, [:png, :svg]
end

describe Asciidoctor::Diagram::WavedromBlockProcessor, :broken_on_windows do
  include_examples "block", :wavedrom, code, [:png, :svg]
end