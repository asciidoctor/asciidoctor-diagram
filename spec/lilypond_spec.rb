require_relative 'test_helper'

code = <<-eos
\\relative c' { f d f a d f e d cis a cis e a g f e }
eos

describe Asciidoctor::Diagram::LilypondBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :lilypond, code, [:png]
end

describe Asciidoctor::Diagram::LilypondBlockProcessor, :broken_on_windows do
  include_examples "block", :lilypond, code, [:png]
end