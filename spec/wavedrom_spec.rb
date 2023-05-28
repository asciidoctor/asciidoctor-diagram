require_relative 'test_helper_methods'

WAVEDROM_CODE = <<-eos
{ signal : [
  { name: "clk",  wave: "p......" },
  { name: "bus",  wave: "x.34.5x",   data: "head body tail" },
  { name: "wire", wave: "0.1..0." },
]}
eos

describe Asciidoctor::Diagram::WavedromInlineMacroProcessor, :broken_on_windows, :broken_on_github do
  include_examples "inline_macro", :wavedrom, WAVEDROM_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::WavedromBlockMacroProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block_macro", :wavedrom, WAVEDROM_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::WavedromBlockProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block", :wavedrom, WAVEDROM_CODE, [:png, :svg]
end