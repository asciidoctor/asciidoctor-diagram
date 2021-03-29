require_relative 'test_helper'

NOMNOML_CODE = <<-eos
[Pirate
  [beard]--[parrot]
  [beard]-:>[foul mouth]
]

[<abstract>Marauder]<:--[Pirate]
[Pirate]- 0..7[mischief]
[jollyness]->[Pirate]
[jollyness]->[rum]
[jollyness]->[singing]
[Pirate]-> *[rum]
[Pirate]->[singing]
[singing]<->[rum]

[<start>st]->[<state>plunder]
[plunder]->[<choice>more loot]
[more loot]->[st]
[more loot] no ->[<end>e]

[<actor>Sailor] - [<usecase>shiver me;timbers]
eos

describe Asciidoctor::Diagram::NomnomlBlockMacroProcessor do
  include_examples "block_macro", :nomnoml, NOMNOML_CODE, [:svg]
end

describe Asciidoctor::Diagram::NomnomlBlockProcessor do
  include_examples "block", :nomnoml, NOMNOML_CODE, [:svg]
end
