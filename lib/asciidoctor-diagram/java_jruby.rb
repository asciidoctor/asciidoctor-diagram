require 'java'

module Asciidoctor
  module Diagram
    module Java
      def self.classpath
        @classpath ||= []
      end

      def self.load
        if @loaded
          return
        end

        classpath.each { |j| require j }
        @loaded = true
      end

      def self.array_to_java_array(array, type)
        array.to_java(type)
      end

      def self.string_from_java_bytes(bytes)
        String.from_java_bytes(bytes)
      end

      def self.method_missing(meth, *args, &block)
        raise "No arguments expected" unless args.empty?
        raise "No block expected" if block

        load
        ::Java.send(meth)
      end
    end
  end
end