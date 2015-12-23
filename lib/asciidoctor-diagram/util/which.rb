module Asciidoctor
  module Diagram
    module Which
      # @private
      def self.which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          }
        end
        nil
      end

      def which(parent_block, cmd, *attr_names)
        attr_names.insert(0, cmd)

        cmd_var = '@' + cmd

        cmd_path = instance_variable_get(cmd_var)
        unless cmd_path
          cmd_path = attr_names.map { |attr_name| parent_block.document.attributes[attr_name] }.find { |attr| !attr.nil? }
          cmd_path = ::Asciidoctor::Diagram::Which.which(cmd) unless cmd_path && File.executable?(cmd_path)
          raise "Could not find the '#{cmd}' executable in PATH; add it to the PATH or specify its location using the '#{attr_names[0]}' document attribute" unless cmd_path
          instance_variable_set(cmd_var, cmd_path)
        end
        cmd_path
      end
    end
  end
end