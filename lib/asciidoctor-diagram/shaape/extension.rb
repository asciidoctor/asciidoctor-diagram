require_relative '../util/cli_generator'
require_relative '../util/diagram'

module Asciidoctor
  module Diagram
    define_processors('Shaape') do
      [:png, :svg].each do |f|
        register_format(f, :image) do |c, p|
          CliGenerator.generate('shaape', p, c) do |tool_path, output_path|
            [tool_path, '-o', output_path, '-t', f.to_s, '-']
          end
        end
      end
    end
  end
end