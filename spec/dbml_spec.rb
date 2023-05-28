require_relative 'test_helper_methods'

DBML_CODE = <<-eos
Table users {
    id integer
    username varchar
    role varchar
    created_at timestamp
}

Table posts {
    id integer [primary key]
    title varchar
    body text [note: 'Content of the post']
    user_id integer
    created_at timestamp
}

Ref: posts.user_id > users.id
eos

describe Asciidoctor::Diagram::DbmlInlineMacroProcessor, :broken_on_windows do
  include_examples "inline_macro", :dbml, DBML_CODE, [:svg]
end

describe Asciidoctor::Diagram::DbmlBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :dbml, DBML_CODE, [:svg]
end

describe Asciidoctor::Diagram::DbmlBlockProcessor, :broken_on_windows do
  include_examples "block", :dbml, DBML_CODE, [:svg]
end
