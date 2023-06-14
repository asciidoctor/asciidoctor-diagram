require_relative '../diagram_converter'
require_relative 'dependencies'

module Asciidoctor
  module Diagram
    # @private
    class BarcodeConverter
      BARCODE_TYPES = [
        :bookland,
        :codabar,
        :code25,
        :code25iata,
        :code25interleaved,
        :code39,
        :code93,
        :code128,
        :code128a,
        :code128b,
        :code128c,
        :ean8,
        :ean13,
        :gs1_128,
        :qrcode,
        :upca,
      ]

      include DiagramConverter

      def supported_formats
        [:svg, :png, :txt]
      end

      def collect_options(source)
        options = {}

        options[:xdim] = source.attr('xdim')
        options[:ydim] = source.attr('ydim')
        options[:margin] = source.attr('margin')
        options[:height] = source.attr('height')
        options[:foreground] = source.attr('foreground')
        options[:background] = source.attr('background')

        [:xdim, :ydim, :margin, :height].each { |o| options[o] = options[o].to_i if options[o] }

        options
      end

      def convert(source, format, options)
        BarcodeDependencies::BARCODE_DEPENDENCIES.each_pair { |n, v| source.ensure_gem(n, v) }
        require 'barby'

        code = source.code
        type = source.config[:type]

        begin
          case type
            when :bookland
              require 'barby/barcode/bookland'
              barcode = Barby::Bookland.new(code)
            when :codabar
              require 'barby/barcode/codabar'
              barcode = Barby::Codabar.new(code)
            when :code25
              require 'barby/barcode/code_25'
              barcode = Barby::Code25.new(code)
            when :code25iata
              require 'barby/barcode/code_25_iata'
              barcode = Barby::Code25IATA.new(code)
            when :code25interleaved
              require 'barby/barcode/code_25_interleaved'
              barcode = Barby::Code25Interleaved.new(code)
            when :code39
              require 'barby/barcode/code_39'
              barcode = Barby::Code39.new(code)
            when :code93
              require 'barby/barcode/code_93'
              barcode = Barby::Code93.new(code)
            when :code128
              require 'barby/barcode/code_128'
              barcode = Barby::Code128.new(code)
            when :code128a
              require 'barby/barcode/code_128'
              barcode = Barby::Code128A.new(code)
            when :code128b
              require 'barby/barcode/code_128'
              barcode = Barby::Code128B.new(code)
            when :code128c
              require 'barby/barcode/code_128'
              barcode = Barby::Code128C.new(code)
            when :ean8
              require 'barby/barcode/ean_8'
              barcode = Barby::EAN8.new(code)
            when :ean13
              require 'barby/barcode/ean_13'
              barcode = Barby::EAN13.new(code)
            when :gs1_128
              require 'barby/barcode/code_128'
              gs1_code = code.gsub /\([^)]+\)/ do |control|
                case control.upcase
                  when '(FNC1)'
                    Barby::Code128::FNC1
                  when '(FNC2)'
                    Barby::Code128::FNC2
                  when '(FNC3)'
                    Barby::Code128::FNC3
                  when '(FNC4)'
                    Barby::Code128::FNC4
                  when '(CODEA)'
                    Barby::Code128::CODEA
                  when '(CODEB)'
                    Barby::Code128::CODEB
                  when '(CODEC)'
                    Barby::Code128::CODEC
                  when '(SHIFT)'
                    Barby::Code128::SHIFT
                  when '(SP)'
                    ' '
                  else
                    control
                end
              end
              gs1_code = gs1_code.gsub(/\s+/, '')
              gs1_code = gs1_code.prepend(Barby::Code128::FNC1) unless gs1_code[0] == Barby::Code128::FNC1
              barcode = Barby::Code128.new(gs1_code)
            when :qrcode
              BarcodeDependencies::QRCODE_DEPENDENCIES.each_pair { |n, v| source.ensure_gem(n, v) }
              require 'barby/barcode/qr_code'
              barcode = Barby::QrCode.new(code)
            when :upca
              require 'barby/barcode/ean_13'
              barcode = Barby::UPCA.new(code)
            else
              raise "Unsupported barcode type: #{type}"
          end
        rescue ArgumentError
          raise "Invalid #{type} data"
        end

        case format
          when :png
            BarcodeDependencies::PNG_DEPENDENCIES.each_pair { |n, v| source.ensure_gem(n, v) }
            require 'barby/outputter/png_outputter'
            require 'chunky_png/color'
            options[:foreground] = ChunkyPNG::Color(options[:foreground]) if options[:foreground]
            options[:background] = ChunkyPNG::Color(options[:background]) if options[:background]
            barcode.to_png(options)
          when :svg
            require_relative 'svg_outputter'
            options[:title] = code
            options[:foreground] = "##{options[:foreground]}" if options[:foreground] =~ /^[0-9a-f]+$/i
            options[:background] = "##{options[:background]}" if options[:background] =~ /^[0-9a-f]+$/i
            barcode.to_svg(options)
          when :txt
            require 'barby/outputter/ascii_outputter'
            barcode.to_ascii
          else
            raise "Unsupported format: #{format}"
        end
      end
    end
  end
end
