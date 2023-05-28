require_relative 'test_helper_methods'

STRUCTURIZR_CODE = <<-eos
workspace {

    model {
        user = person "User"
        softwareSystem = softwareSystem "Software System" {
            webapp = container "Web Application" {
                user -> this "Uses"
            }
            container "Database" {
                webapp -> this "Reads from and writes to"
            }
        }
    }

    views {
        systemContext softwareSystem {
            include *
            autolayout lr
        }

        container softwareSystem {
            include *
            autolayout lr
        }

        theme default
    }

}
eos

describe Asciidoctor::Diagram::StructurizrBlockMacroProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block_macro", :structurizr, STRUCTURIZR_CODE, [:png, :png]
end

describe Asciidoctor::Diagram::StructurizrBlockProcessor, :broken_on_windows, :broken_on_github do
  include_examples "block", :structurizr, STRUCTURIZR_CODE, [:png, :png]
end
