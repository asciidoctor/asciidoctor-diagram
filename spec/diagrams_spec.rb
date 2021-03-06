require_relative 'test_helper'

code = <<-eos
from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB

with Diagram("Grouped Workers", show=False, direction="TB"):
    ELB("lb") >> [EC2("worker1"),
                  EC2("worker2"),
                  EC2("worker3"),
                  EC2("worker4"),
                  EC2("worker5")] >> RDS("events")
eos

describe Asciidoctor::Diagram::DiagramsBlockMacroProcessor do
  include_examples "block_macro", :diagrams, code, [:png, :svg]
end

describe Asciidoctor::Diagram::DiagramsBlockProcessor do
  include_examples "block", :diagrams, code, [:png, :svg]
end