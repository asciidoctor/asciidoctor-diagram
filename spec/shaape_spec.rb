require_relative 'test_helper'

CODE = <<-eos
        +-->
       /     /\
  >---+---->+  +
             \/
eos

describe Asciidoctor::Diagram::ShaapeBlockMacroProcessor, :broken_on_osx, :broken_on_github, :broken_on_windows do
  include_examples "block_macro", :shaape, CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::ShaapeBlockProcessor, :broken_on_osx, :broken_on_github, :broken_on_windows do
  include_examples "block", :shaape, CODE, [:png, :svg]
end
