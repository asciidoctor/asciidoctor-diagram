require_relative 'test_helper'

SHAAPE_CODE = <<-eos
        +-->
       /     /\
  >---+---->+  +
             \/
eos

describe Asciidoctor::Diagram::ShaapeBlockMacroProcessor, :broken_on_osx, :broken_on_github, :broken_on_windows do
  include_examples "block_macro", :shaape, SHAAPE_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::ShaapeBlockProcessor, :broken_on_osx, :broken_on_github, :broken_on_windows do
  include_examples "block", :shaape, SHAAPE_CODE, [:png, :svg]
end
