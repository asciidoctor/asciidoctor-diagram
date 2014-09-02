require_relative '../util/cli_generator'
require_relative '../util/diagram'
require 'net/https'

module Asciidoctor
  module Diagram
    module CacooGenerator
      def self.cacoo(c)
        apiKey = ENV['CACOO_API_KEY']
        diagramId = c.strip
        # NOTE: See API document at https://cacoo.com/lang/en/api and
        # https://cacoo.com/lang/en/api_image
        url = "/api/v1/diagrams/#{diagramId}.png?apiKey=#{apiKey}"

        https = Net::HTTP.new('cacoo.com', 443)
        https.use_ssl = true
        https.start {
          response = https.get(url)
          raise "Cacoo response status code was #{response.code}" if response.code != '200'
          response.body
        }
      end
    end

    define_processors('Cacoo') do
      register_format(:png, :image) do |c|
        CacooGenerator.cacoo(c)
      end
    end
  end
end
