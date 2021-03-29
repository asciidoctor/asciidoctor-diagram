require_relative 'test_helper'

TIKZ_CODE = <<-'eos'
\begin{tikzpicture}[font=\LARGE] 

% Figure parameters (tta and k needs to have the same sign)
% They can be modified at will
\def \tta{ -10.00000000000000 } % Defines the first angle of perspective
\def \k{    -3.00000000000000 } % Factor for second angle of perspective
\def \l{     6.00000000000000 } % Defines the width  of the parallelepiped
\def \d{     5.00000000000000 } % Defines the depth  of the parallelepiped
\def \h{     7.00000000000000 } % Defines the heigth of the parallelepiped

% The vertices A,B,C,D define the reference plan (vertical)
\coordinate (A) at (0,0); 
\coordinate (B) at ({-\h*sin(\tta)},{\h*cos(\tta)}); 
\coordinate (C) at ({-\h*sin(\tta)-\d*sin(\k*\tta)},
                    {\h*cos(\tta)+\d*cos(\k*\tta)}); 
\coordinate (D) at ({-\d*sin(\k*\tta)},{\d*cos(\k*\tta)}); 

% The vertices Ap,Bp,Cp,Dp define a plane translated from the 
% reference plane by the width of the parallelepiped
\coordinate (Ap) at (\l,0); 
\coordinate (Bp) at ({\l-\h*sin(\tta)},{\h*cos(\tta)}); 
\coordinate (Cp) at ({\l-\h*sin(\tta)-\d*sin(\k*\tta)},
                     {\h*cos(\tta)+\d*cos(\k*\tta)}); 
\coordinate (Dp) at ({\l-\d*sin(\k*\tta)},{\d*cos(\k*\tta)}); 

% Marking the vertices of the tetrahedron (red)
% and of the parallelepiped (black)
\fill[black]  (A) circle [radius=2pt]; 
\fill[red]    (B) circle [radius=2pt]; 
\fill[black]  (C) circle [radius=2pt]; 
\fill[red]    (D) circle [radius=2pt]; 
\fill[red]   (Ap) circle [radius=2pt]; 
\fill[black] (Bp) circle [radius=2pt]; 
\fill[red]   (Cp) circle [radius=2pt]; 
\fill[black] (Dp) circle [radius=2pt]; 

% painting first the three visible faces of the tetrahedron
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (Cp) -- (D);
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (D)  -- (Ap);
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (Cp) -- (Ap);

% Draw the edges of the tetrahedron
\draw[red,-,very thick] (Ap) --  (D)
                        (Ap) --  (B)
                        (Ap) -- (Cp)
                        (B)  --  (D)
                        (Cp) --  (D)
                        (B)  -- (Cp);

% Draw the visible edges of the parallelepiped
\draw [-,thin] (B)  --  (A)
               (Ap) -- (Bp)
               (B)  --  (C)
               (D)  --  (C)
               (A)  --  (D)
               (Ap) --  (A)
               (Cp) --  (C)
               (Bp) --  (B)
               (Bp) -- (Cp);

% Draw the hidden edges of the parallelepiped
\draw [gray,-,thin] (Dp) -- (Cp);
                    (Dp) --  (D);
                    (Ap) -- (Dp);

% Name the vertices (the names are not consistent
%  with the node name, but it makes the programming easier)
\draw (Ap) node [right]           {$A$}
      (Bp) node [right, gray]     {$F$}
      (Cp) node [right]           {$D$}
      (C)  node [left,gray]       {$E$}
      (D)  node [left]            {$B$}
      (A)  node [left,gray]       {$G$}
      (B)  node [above left=+5pt] {$C$}
      (Dp) node [right,gray]      {$H$};

% Drawing again vertex $C$, node (B) because it disappeared behind the edges.
% Drawing again vertex $H$, node (Dp) because it disappeared behind the edges.
\fill[red]   (B) circle [radius=2pt]; 
\fill[gray] (Dp) circle [radius=2pt]; 

% From the reference and this example one can easily draw 
% the twin tetrahedron jointly to this one.
% Drawing the edges of the twin tetrahedron
% switching the p_s: A <-> Ap, etc...
\draw[red,-,dashed, thin] (A)  -- (Dp)
                          (A)  -- (Bp)
                          (A)  --  (C)
                          (Bp) -- (Dp)
                          (C)  -- (Dp)
                          (Bp) --  (C);
\end{tikzpicture}
eos

describe Asciidoctor::Diagram::TikZBlockMacroProcessor, :broken_on_windows do
  include_examples "block_macro", :tikz, TIKZ_CODE, [:pdf]
end

describe Asciidoctor::Diagram::TikZBlockProcessor, :broken_on_windows do
  include_examples "block", :tikz, TIKZ_CODE, [:pdf]
  
  it "should support the preamble attribute" do
      File.write("tikz.txt", TIKZ_CODE)

      doc = <<'eos'
= Hello, tikz!
Doc Writer <doc@example.com>

== First Section

[tikz, preamble="true"]
----
\usepackage{tkz-euclide}
\usepackage{etoolbox}
\usepackage{MnSymbol}
\usetikzlibrary{angles,patterns,calc}
\usepackage[most]{tcolorbox}
\usepackage{pgfplots}
\pgfplotsset{compat=1.7}
~~~~
\begin{tikzpicture}
\tikzset{>=stealth}
% draw axises and labels. We store a single coordinate to have the
% direction of the x axis
\draw[->] (-4,0) -- ++(8,0) coordinate (X) node[below] {$x$};
\draw[->] (0,-4) -- ++(0,8) node[left] {$y$};

\newcommand\CircleRadius{3cm}
\draw (0,0) circle (\CircleRadius);
% special method of noting the position of a point
\coordinate (P) at (-495:\CircleRadius);

\draw[thick]
(0,0)
coordinate (O) % store origin
node[] {} % label
--
node[below left, pos=1] {$P(-\frac{\sqrt{2}}{2}, -\frac{\sqrt{2}}{2})$} % some labels
node[below right, midway] {$r$}
(P)
--
node[midway,left] {$y$}
(P |- O) coordinate (Px) % projection onto horizontal line through
                            % O, saved for later
--
node[midway, below] {$x$}
cycle % closed path

% pic trick is from the angles library, requires the three points of
% the marked angle to be named

pic [] {angle=X--O--P};
\draw[->,red] (5mm, 0mm) arc (0:-495:5mm) node[midway,xshift=-4mm,yshift=3.5mm] {$-495^\circ$};
% right angle marker
\draw ($(Px)+(0.3, 0)$) -- ++(0, -0.3) -- ++(-0.3,0);
\end{tikzpicture}
----
eos

      d = load_asciidoc doc
      expect(d).to_not be_nil

      b = d.find { |bl| bl.context == :image }
      expect(b).to_not be_nil

      expect(b.content_model).to eq :empty

      target = b.attributes['target']
      expect(target).to_not be_nil
  end
end
