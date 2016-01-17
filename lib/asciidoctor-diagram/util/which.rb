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
        attr_names = options[:attr_names] || [cmd]

        cmd_var = '@' + attr_names[0]

        already_defined = instance_variable_defined?(cmd_var)

        if already_defined
          cmd_path = instance_variable_get(cmd_var)
        else
          cmd_path = attr_names.map { |attr_name| parent_block.document.attributes[attr_name] }.find { |attr| !attr.nil? }
          cmd_path = ::Asciidoctor::Diagram::Which.which(cmd, :path => options[:path]) unless cmd_path && File.executable?(cmd_path)
          instance_variable_set(cmd_var, cmd_path)
          if cmd_path.nil? && options.fetch(:raise_on_error, true)
            raise "Could not find the '#{cmd}' executable in PATH; add it to the PATH or specify its location using the '#{attr_names[0]}' document attribute"
          end
        end

        cmd_path
      end
    end
  end
end