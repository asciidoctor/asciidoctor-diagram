require_relative '../util/cli_generator'
require_relative '../util/diagram'

module Asciidoctor
  module Diagram
    define_processors('Graphviz') do
      [:png, :svg].each do |f|
        register_format(f, :image) do |c, p|
          CliGenerator.generate('dot', p, c) do |tool_path, output_path|
            [tool_path, "-o#{output_path}", "-T#{f.to_s}"]
          end
        end
      end
    end
  end
end
