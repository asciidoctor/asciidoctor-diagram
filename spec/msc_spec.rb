require_relative 'test_helper'

MSC_CODE = <<-eos
# MSC for some fictional process
msc {
  hscale = "2";

  a,b,c;

  a->b [ label = "ab()" ] ;
  b->c [ label = "bc(TRUE)"];
  c=>c [ label = "process(1)" ];
  c=>c [ label = "process(2)" ];
  ...;
  c=>c [ label = "process(n)" ];
  c=>c [ label = "process(END)" ];
  a<<=c [ label = "callback()"];
  ---  [ label = "If more to run", ID="*" ];
  a->a [ label = "next()"];
  a->c [ label = "ac1()\nac2()"];
  b<-c [ label = "cb(TRUE)"];
  b->b [ label = "stalled(...)"];
  a<-b [ label = "ab() = FALSE"];
}
eos

describe Asciidoctor::Diagram::MscBlockMacroProcessor do
  include_examples "block_macro", :msc, MSC_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::MscBlockProcessor do
  include_examples "block", :msc, MSC_CODE, [:png, :svg]
end
