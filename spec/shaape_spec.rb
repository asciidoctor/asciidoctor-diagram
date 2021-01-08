require_relative 'test_helper'

code = <<-eos
        +-->
       /     /\
  >---+---->+  +
             \/
eos

describe Asciidoctor::Diagram::ShaapeBlockMacroProcessor, :broken_on_osx, :broken_on_travis, :broken_on_windows do
  include_examples "block_macro", :shaape, code, [:png, :svg]
end

describe Asciidoctor::Diagram::ShaapeBlockProcessor, :broken_on_osx, :broken_on_travis, :broken_on_windows do
  include_examples "block", :shaape, code, [:png, :svg]
end
