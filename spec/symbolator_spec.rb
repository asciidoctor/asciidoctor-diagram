require_relative 'test_helper'

code = <<-eos
library ieee;
use ieee.std_logic_1164.all;

package demo is
  component demo_device is
    generic (
      SIZE : positive;
      RESET_ACTIVE_LEVEL : std_ulogic := '1'
    );
  end component;
end package;
eos

describe Asciidoctor::Diagram::SymbolatorBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :symbolator, code, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::SymbolatorBlockProcessor, :broken_on_windows do
  include_examples "block", :symbolator, code, [:png, :svg, :pdf]
end
