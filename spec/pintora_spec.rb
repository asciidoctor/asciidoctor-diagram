require_relative 'test_helper_methods'

PINTORA_CODE = <<EOF
componentDiagram
  [Pintora] --> [DiagramRegistry] : Get diagram by type
EOF

describe Asciidoctor::Diagram::PintoraInlineMacroProcessor do
  include_examples "inline_macro", :pintora, PINTORA_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::PintoraBlockMacroProcessor do
  include_examples "block_macro", :pintora, PINTORA_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::PintoraBlockProcessor do
  include_examples "block", :pintora, PINTORA_CODE, [:png, :svg]
end