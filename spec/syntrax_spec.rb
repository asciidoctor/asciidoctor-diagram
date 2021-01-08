require_relative 'test_helper'

code = <<-eos
indentstack(10,
  line(opt('-'), choice('0', line('1-9', loop(None, '0-9'))),
    opt('.', loop('0-9', None))),

  line(opt(choice('e', 'E'), choice(None, '+', '-'), loop('0-9', None)))
)
eos

describe Asciidoctor::Diagram::SyntraxBlockMacroProcessor, :broken_on_osx, :broken_on_windows do
  include_examples "block_macro", :syntrax, code, [:png, :svg]
end

describe Asciidoctor::Diagram::SyntraxBlockProcessor, :broken_on_osx, :broken_on_windows do
  include_examples "block", :syntrax, code, [:png, :svg]
end
