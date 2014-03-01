require 'rjb'

module Asciidoctor
  module Diagram
    module Java
      INITAWT_JAR_PATH = File.expand_path File.join('..', 'initawt.jar'), File.dirname(__FILE__)

      module Package
        def method_missing(meth, *args, &block)
          raise "No arguments expected" unless args.empty?
          raise "No block expected" if block

          name = meth.to_s
          @proxies ||= {}
          @proxies[name] ||= create_java_proxy(name)
        end

        private

        def create_java_proxy(name)
          qualified_name = @name ? "#{@name}.#{name}" : name
          if name =~ /^[[:upper:]]/
            Package.create_class(qualified_name)
          else
            Package.create_package(qualified_name)
          end
        end

        def self.create_class(name)
          ::Rjb.import(name)
        end

        def self.create_package(name)
          package = Module.new
          package.extend Package
          package.instance_variable_set :@name, name
          package.instance_variable_set :@parent, name
          package
        end
      end

      def self.classpath
        @classpath ||= []
      end

      def self.load
        if @loaded
          return
        end

        Rjb::load(classpath.join(File::PATH_SEPARATOR))

        # On OS X using AWT from JNI is extremely deadlock prone. Enabling AWT headless mode resolves this issue. We're
        # never actually going to display an AWT GUI, so this should be fairly safe.
        Rjb::import('java.lang.System').setProperty 'java.awt.headless', 'true'

        @loaded = true
      end

      def self.array_to_java_array(array, type)
        # Rjb does not require an explicit conversion of a Ruby Array containing Ruby Strings to a Ruby Array containing
        # Java Strings. It handles this implicitly when calling Java methods.
        array
      end

      def self.string_from_java_bytes(bytes)
        # Rjb implictly converts Java byte arrays to Ruby Strings so nothing needs to be done here
        bytes
      end

      def self.method_missing(meth, *args, &block)
        raise "No arguments expected" unless args.empty?
        raise "No block expected" if block

        load

        @root_package ||= Package.send(:create_package, nil)
        @root_package.send(meth, *args)
      end

      def self.new_object(java_class, signature = nil, *args)
        if signature
          java_class.new_with_sig(signature, *args)
        else
          java_class.new(*args)
        end
      end
    end
  end
end