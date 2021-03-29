require_relative 'test_helper'

SYMBOLATOR_CODE = <<-eos
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
  include_examples "block_macro", :symbolator, SYMBOLATOR_CODE, [:png, :svg, :pdf]
end

describe Asciidoctor::Diagram::SymbolatorBlockProcessor, :broken_on_windows do
  include_examples "block", :symbolator, SYMBOLATOR_CODE, [:png, :svg, :pdf]
end
