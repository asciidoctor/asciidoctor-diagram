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

STRUCTURIZR_JSON = <<-eos
{
  "configuration" : { },
  "description" : "Description",
  "documentation" : { },
  "id" : 0,
  "model" : {
    "people" : [ {
      "id" : "1",
      "location" : "Unspecified",
      "name" : "User",
      "properties" : {
        "structurizr.dsl.identifier" : "user"
      },
      "relationships" : [ {
        "description" : "Uses",
        "destinationId" : "3",
        "id" : "4",
        "properties" : {
          "structurizr.dsl.identifier" : "0363ae3f-212d-4ee8-bebf-313edcba3598"
        },
        "sourceId" : "1",
        "tags" : "Relationship"
      }, {
        "description" : "Uses",
        "destinationId" : "2",
        "id" : "5",
        "linkedRelationshipId" : "4",
        "sourceId" : "1"
      } ],
      "tags" : "Element,Person"
    } ],
    "softwareSystems" : [ {
      "containers" : [ {
        "documentation" : { },
        "id" : "3",
        "name" : "Web Application",
        "properties" : {
          "structurizr.dsl.identifier" : "webapp"
        },
        "relationships" : [ {
          "description" : "Reads from and writes to",
          "destinationId" : "6",
          "id" : "7",
          "properties" : {
            "structurizr.dsl.identifier" : "c49e4f5c-2db2-460e-90e3-231621b4bd29"
          },
          "sourceId" : "3",
          "tags" : "Relationship"
        } ],
        "tags" : "Element,Container"
      }, {
        "documentation" : { },
        "id" : "6",
        "name" : "Database",
        "properties" : {
          "structurizr.dsl.identifier" : "821f7237-3ee2-40d4-afed-c42b68632055"
        },
        "tags" : "Element,Container"
      } ],
      "documentation" : { },
      "id" : "2",
      "location" : "Unspecified",
      "name" : "Software System",
      "properties" : {
        "structurizr.dsl.identifier" : "softwaresystem"
      },
      "tags" : "Element,Software System"
    } ]
  },
  "name" : "Name",
  "properties" : {
    "structurizr.dsl" : "d29ya3NwYWNlIHsKCiAgICBtb2RlbCB7CiAgICAgICAgdXNlciA9IHBlcnNvbiAiVXNlciIKICAgICAgICBzb2Z0d2FyZVN5c3RlbSA9IHNvZnR3YXJlU3lzdGVtICJTb2Z0d2FyZSBTeXN0ZW0iIHsKICAgICAgICAgICAgd2ViYXBwID0gY29udGFpbmVyICJXZWIgQXBwbGljYXRpb24iIHsKICAgICAgICAgICAgICAgIHVzZXIgLT4gdGhpcyAiVXNlcyIKICAgICAgICAgICAgfQogICAgICAgICAgICBjb250YWluZXIgIkRhdGFiYXNlIiB7CiAgICAgICAgICAgICAgICB3ZWJhcHAgLT4gdGhpcyAiUmVhZHMgZnJvbSBhbmQgd3JpdGVzIHRvIgogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQoKICAgIHZpZXdzIHsKICAgICAgICBzeXN0ZW1Db250ZXh0IHNvZnR3YXJlU3lzdGVtIHsKICAgICAgICAgICAgaW5jbHVkZSAqCiAgICAgICAgICAgIGF1dG9sYXlvdXQgbHIKICAgICAgICB9CgogICAgICAgIGNvbnRhaW5lciBzb2Z0d2FyZVN5c3RlbSB7CiAgICAgICAgICAgIGluY2x1ZGUgKgogICAgICAgICAgICBhdXRvbGF5b3V0IGxyCiAgICAgICAgfQoKICAgICAgICB0aGVtZSBkZWZhdWx0CiAgICB9Cgp9Cg=="
  },
  "views" : {
    "configuration" : {
      "branding" : { },
      "styles" : { },
      "terminology" : { },
      "themes" : [ "https://static.structurizr.com/themes/default/theme.json" ]
    },
    "containerViews" : [ {
      "automaticLayout" : {
        "applied" : false,
        "edgeSeparation" : 0,
        "implementation" : "Graphviz",
        "nodeSeparation" : 300,
        "rankDirection" : "LeftRight",
        "rankSeparation" : 300,
        "vertices" : false
      },
      "elements" : [ {
        "id" : "1",
        "x" : 0,
        "y" : 0
      }, {
        "id" : "3",
        "x" : 0,
        "y" : 0
      }, {
        "id" : "6",
        "x" : 0,
        "y" : 0
      } ],
      "externalSoftwareSystemBoundariesVisible" : false,
      "generatedKey" : true,
      "key" : "Container-001",
      "order" : 2,
      "relationships" : [ {
        "id" : "4"
      }, {
        "id" : "7"
      } ],
      "softwareSystemId" : "2"
    } ],
    "systemContextViews" : [ {
      "automaticLayout" : {
        "applied" : false,
        "edgeSeparation" : 0,
        "implementation" : "Graphviz",
        "nodeSeparation" : 300,
        "rankDirection" : "LeftRight",
        "rankSeparation" : 300,
        "vertices" : false
      },
      "elements" : [ {
        "id" : "1",
        "x" : 0,
        "y" : 0
      }, {
        "id" : "2",
        "x" : 0,
        "y" : 0
      } ],
      "enterpriseBoundaryVisible" : true,
      "generatedKey" : true,
      "key" : "SystemContext-001",
      "order" : 1,
      "relationships" : [ {
        "id" : "5"
      } ],
      "softwareSystemId" : "2"
    } ]
  }
}
eos

describe Asciidoctor::Diagram::StructurizrBlockMacroProcessor, :broken_on_windows, :broken_on_github do
  context "dsl" do
    include_examples "block_macro", :structurizr, STRUCTURIZR_CODE, [:png, :png]
  end

  context "json" do
    include_examples "block_macro", :structurizr, STRUCTURIZR_JSON, [:png, :png]
  end
end

describe Asciidoctor::Diagram::StructurizrBlockProcessor, :broken_on_windows, :broken_on_github do
  context "dsl" do
    include_examples "block", :structurizr, STRUCTURIZR_CODE, [:png, :png]
  end

  context "json" do
    include_examples "block", :structurizr, STRUCTURIZR_JSON, [:png, :png]
  end
end
