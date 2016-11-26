module Asciidoctor
  module Diagram
    module Which
      # @private
      def self.which(cmd, options = {})
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

        paths = (options[:path] || []) + ENV['PATH'].split(File::PATH_SEPARATOR)
        paths.each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          }
        end

        nil
      end

      def which(parent_block, cmd, options = {})
        attr_names = options.fetch(:alt_attrs, []) + [cmd]
        cmd_names = [cmd] + options.fetch(:alt_cmds, [])

        cmd_var = '@' + attr_names[0]

        if instance_variable_defined?(cmd_var)
          cmd_path = instance_variable_get(cmd_var)
        else
          cmd_path = attr_names.map { |attr_name| parent_block.attr(attr_name, nil, true) }.find { |attr| !attr.nil? }

          unless cmd_path && File.executable?(cmd_path)
            cmd_paths = cmd_names.map do |c|
              ::Asciidoctor::Diagram::Which.which(c, :path => options[:path])
            end

            cmd_path = cmd_paths.reject { |c| c.nil? }.first
          end

          instance_variable_set(cmd_var, cmd_path)

          if cmd_path.nil? && options.fetch(:raise_on_error, true)
            raise "Could not find the #{cmd_names.map { |c| "'#{c}'" }.join(', ')} executable in PATH; add it to the PATH or specify its location using the '#{attr_names[0]}' document attribute"
          end
        end

        cmd_path
      end

      def which_jar(parent_block, jar, options = {})

        attr_names = options.fetch(:alt_attrs, []) + ["uri-#{jar}-jar"]

        jar_var = '@_' + attr_names[0].gsub("-", "_")

        if instance_variable_defined?(jar_var)
          jar_path = instance_variable_get(jar_var)
        else

          jar_paths = attr_names.map { |attr_name|
            parent_block.attr(attr_name, nil, true)
          }

          jar_paths += [find_jar_classpath(jar), "/usr/share/#{jar}/#{jar}.jar", "/usr/share/java/#{jar}.jar"]
          jar_paths.compact!

          jar_path = jar_paths.map { |c|
            c if File.readable?(c)
          }.compact.first

          instance_variable_set(jar_var, jar_path)
        end

        if jar_path.nil? && options.fetch(:raise_on_error, true)
          raise "Could not find the #{jar} jar file in CLASSPATH; add it to CLASSPATH or specify its location using the uri-#{jar}-jar document attribute"
        end

        return [jar_path]
      end

      def find_jar_classpath(jar)
        if ENV["CLASSPATH"]
          ENV["CLASSPATH"].split(Platform.classpath_separator).select { |j| j.end_with?("#{jar}.jar") }.first
        end
      end
    end
  end
end
