require_relative 'test_helper'

CODE = <<-eos
\\relative c' { f d f a d f e d cis a cis e a g f e }
eos

describe Asciidoctor::Diagram::LilypondBlockMacroProcessor do
  include_examples "block_macro", :lilypond, CODE, [:png]
end

describe Asciidoctor::Diagram::LilypondBlockProcessor do
  include_examples "block", :lilypond, CODE, [:png]
end
