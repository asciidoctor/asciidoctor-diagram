module Asciidoctor
  module Diagram
    module BarcodeDependencies
      BARCODE_DEPENDENCIES = {'barby' => '~> 0.6.8'}
      PNG_DEPENDENCIES = {'chunky_png' => '~> 1.4'}
      QRCODE_DEPENDENCIES = {'rqrcode' => '~> 2.0'}
      ALL_DEPENDENCIES = {}.merge(BARCODE_DEPENDENCIES).merge(PNG_DEPENDENCIES).merge(QRCODE_DEPENDENCIES)
    end
  end
end