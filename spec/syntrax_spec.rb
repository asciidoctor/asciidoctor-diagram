require_relative 'test_helper_methods'

SYNTRAX_CODE = <<-eos
indentstack(10,
  line(opt('-'), choice('0', line('1-9', loop(None, '0-9'))),
    opt('.', loop('0-9', None))),

  line(opt(choice('e', 'E'), choice(None, '+', '-'), loop('0-9', None)))
)
eos

describe Asciidoctor::Diagram::SyntraxInlineMacroProcessor, :broken_on_windows, :broken_on_github do
  include_examples "inline_macro", :syntrax, SYNTRAX_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::SyntraxBlockMacroProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block_macro", :syntrax, SYNTRAX_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::SyntraxBlockProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block", :syntrax, SYNTRAX_CODE, [:png, :svg]
end
