module Asciidoctor
  module Diagram
    module Base64
      def self.urlsafe_encode(bin, padding: true)
        str = [bin].pack("m0")
        str.chomp!("==") or str.chomp!("=") unless padding
        str.tr!("+/", "-_")
        str
      end

      def self.urlsafe_decode(str)
        # NOTE: RFC 4648 does say nothing about unpadded input, but says that
        # "the excess pad characters MAY also be ignored", so it is inferred that
        # unpadded input is also acceptable.
        if !str.end_with?("=") && str.length % 4 != 0
          str = str.ljust((str.length + 3) & ~3, "=")
          str.tr!("-_", "+/")
        else
          str = str.tr("-_", "+/")
        end
        str.unpack1("m0")
      end
    end
  end
end