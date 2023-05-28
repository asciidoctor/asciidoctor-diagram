require_relative 'test_helper_methods'

LILYPOND_CODE = <<-eos
\\relative c' { f d f a d f e d cis a cis e a g f e }
eos

describe Asciidoctor::Diagram::LilypondInlineMacroProcessor, :broken_on_windows do
  include_examples "inline_macro", :lilypond, LILYPOND_CODE, [:png]
end

describe Asciidoctor::Diagram::LilypondBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :lilypond, LILYPOND_CODE, [:png]
end

describe Asciidoctor::Diagram::LilypondBlockProcessor, :broken_on_windows do
  include_examples "block", :lilypond, LILYPOND_CODE, [:png]
end
