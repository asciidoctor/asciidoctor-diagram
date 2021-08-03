require_relative '../diagram_converter'
require 'barby'

module Asciidoctor
  module Diagram
    # @private
    class BarcodeConverter
      include DiagramConverter

      def supported_formats
        [:png, :txt]
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
        source.ensure_gem('barby', '~> 0.6.8')
        require 'barby'

        code = source.code
        type = source.attr('type')

        case type
          when 'bookland'
            require 'barby/barcode/bookland'
            barcode = Barby::Bookland.new(code)
          when 'codabar'
            require 'barby/barcode/codabar'
            barcode = Barby::Codabar.new(code)
          when 'code25', 'code_25'
            require 'barby/barcode/code_25'
            barcode = Barby::Code25.new(code)
          when 'code25iata', 'code_25_iata'
            require 'barby/barcode/code_25_iata'
            barcode = Barby::Code25IATA.new(code)
          when 'code25interleaved', 'code_25_interleaved'
            require 'barby/barcode/code_25_interleaved'
            barcode = Barby::Code25Interleaved.new(code)
          when 'code39', 'code_39'
            require 'barby/barcode/code_39'
            barcode = Barby::Code39.new(code)
          when 'code93', 'code_93'
            require 'barby/barcode/code_93'
            barcode = Barby::Code93.new(code)
          when 'code128', 'code_128'
            require 'barby/barcode/code_128'
            barcode = Barby::Code128.new(code)
          when 'code128a', 'code_128a'
            require 'barby/barcode/code_128'
            barcode = Barby::Code128A.new(code)
          when 'code128b', 'code_128b'
            require 'barby/barcode/code_128'
            barcode = Barby::Code128B.new(code)
          when 'code128c', 'code_128c'
            require 'barby/barcode/code_128'
            barcode = Barby::Code128C.new(code)
          when 'ean8', 'ean_8'
            require 'barby/barcode/ean_8'
            barcode = Barby::EAN8.new(code)
          when 'ean13', 'ean_13'
            require 'barby/barcode/ean_13'
            barcode = Barby::EAN13.new(code)
          when 'gs1_128'
            require 'barby/barcode/code_128'
            code = code.gsub /\[[^\]]+\]/ do |control|
              case control.upcase
                when '[FNC1]'
                  Barby::Code128::FNC1
                when '[FNC2]'
                  Barby::Code128::FNC2
                when '[FNC3]'
                  Barby::Code128::FNC3
                when '[FNC4]'
                  Barby::Code128::FNC4
                when '[CODEA]'
                  Barby::Code128::CODEA
                when '[CODEB]'
                  Barby::Code128::CODEB
                when '[CODEC]'
                  Barby::Code128::CODEC
                when '[SHIFT]'
                  Barby::Code128::SHIFT
                else
                  raise "Unsupported control sequence: #{m.group(1)}"
              end
            end
            code = code.gsub(/\s+/, '')
            code = code.prepend(Barby::Code128::FNC1) unless code[0] == Barby::Code128::FNC1
            barcode = Barby::Code128.new(code)
          when 'pdf417', 'pdf_417'
            require 'barby/barcode/pdf_417'
            barcode = Barby::Pdf417.new(code)
          when 'qr', 'qrcode', 'qr_code'
            source.ensure_gem('rqrcode', '~> 2.0.0')
            require 'barby/barcode/qr_code'
            barcode = Barby::QrCode.new(code)
          when 'upca', 'upc_a'
            require 'barby/barcode/ean_13'
            barcode = Barby::UPCA.new(code)
          else
            raise "Unsupported barcode type: #{type}"
        end

        case format
          when :png
            source.ensure_gem('chunky_png', '~> 1.4.0')
            require 'barby/outputter/png_outputter'
            barcode.to_png(options)
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
