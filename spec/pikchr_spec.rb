require_relative 'test_helper'

PIKCHR_CODE = <<-eos
# Change from the original:
#    * Expand the macro by hand, as Pikchr does not support
#      macros
#
#define ndblock {
#  box wid boxwid/2 ht boxht/2
#  down;  box same with .t at bottom of last box;   box same
#}
boxht = .2; boxwid = .3; circlerad = .3; dx = 0.05
down; box; box; box; box ht 3*boxht "." "." "."
L: box; box; box invis wid 2*boxwid "hashtab:" with .e at 1st box .w
right
Start: box wid .5 with .sw at 1st box.ne + (.4,.2) "..."
N1: box wid .2 "n1";  D1: box wid .3 "d1"
N3: box wid .4 "n3";  D3: box wid .3 "d3"
box wid .4 "..."
N2: box wid .5 "n2";  D2: box wid .2 "d2"
arrow right from 2nd box
#ndblock
  box wid boxwid/2 ht boxht/2
  down;  box same with .t at bottom of last box;   box same
spline -> right .2 from 3rd last box then to N1.sw + (dx,0)
spline -> right .3 from 2nd last box then to D1.sw + (dx,0)
arrow right from last box
#ndblock
  box wid boxwid/2 ht boxht/2
  down;  box same with .t at bottom of last box;   box same
spline -> right .2 from 3rd last box to N2.sw-(dx,.2) to N2.sw+(dx,0)
spline -> right .3 from 2nd last box to D2.sw-(dx,.2) to D2.sw+(dx,0)
arrow right 2*linewid from L
#ndblock
  box wid boxwid/2 ht boxht/2
  down;  box same with .t at bottom of last box;   box same
spline -> right .2 from 3rd last box to N3.sw + (dx,0)
spline -> right .3 from 2nd last box to D3.sw + (dx,0)
circlerad = .3
circle invis "ndblock"  at last box.e + (1.2,.2)
arrow dashed from last circle.w to 5/8<last circle.w,2nd last box> chop
box invis wid 2*boxwid "ndtable:" with .e at Start.w
eos

describe Asciidoctor::Diagram::PikchrBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :pikchr, PIKCHR_CODE, [:svg]
end

describe Asciidoctor::Diagram::PikchrBlockProcessor, :broken_on_windows do
  include_examples "block", :pikchr, PIKCHR_CODE, [:svg]

  it "should report syntax errors" do
    doc = <<-eos
= Hello, Pikchr!
Doc Writer <doc@example.com>

== First Section

[pikchr]
----
This should raise a syntax error.
----
    eos

    expect {
      load_asciidoc doc
    }.to raise_error(/error/i)
  end
end
