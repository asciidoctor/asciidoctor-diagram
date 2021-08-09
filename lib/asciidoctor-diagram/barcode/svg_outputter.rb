require 'barby/outputter/svg_outputter'

module Barby
  class SvgOutputter
    # Monkey patch to fix foreground color in SVG output
    def bars_to_path(opts={})
      with_options opts do
        %Q|<path stroke="#{foreground}" stroke-width="#{xdim}" d="#{bars_to_path_data(opts)}" />|
      end
    end
  end
end