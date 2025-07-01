require_relative '../diagram_converter'
require_relative '../util/java'
require_relative '../util/cli'
require_relative '../util/cli_generator'
require 'delegate'
require 'uri'

module Asciidoctor
  module Diagram
    # @private
    class PlantUmlConverter
      include DiagramConverter
      include CliGenerator

      CLASSPATH_ENV = Java.environment_variable('DIAGRAM_PLANTUML_CLASSPATH')
      LIB_DIR = File.expand_path('../..', File.dirname(__FILE__))
      PLANTUML_JARS = if CLASSPATH_ENV
                        CLASSPATH_ENV.split(File::PATH_SEPARATOR)
                      else
                        begin
                          require 'asciidoctor-diagram/plantuml/classpath'
                          ::Asciidoctor::Diagram::PlantUmlClasspath::JAR_FILES
                        rescue LoadError
                          nil
                        end
                      end

      if PLANTUML_JARS
        Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
        Java.classpath.concat PLANTUML_JARS
      end

      def self.find_plantuml_native(source)
        source.find_command(
          'plantuml-full',
          :raise_on_error => false,
          :attrs => ['plantuml-native'],
          :alt_cmds => ['plantuml-headless']
        )
      end

      def wrap_source(source)
        PlantUMLPreprocessedSource.new(source, self)
      end

      def supported_formats
        [:png, :svg, :txt, :atxt, :utxt]
      end

      def collect_options(source)
        options = {
            :size_limit => source.attr('size-limit', '4096'),
        }

        options[:smetana] = true if source.opt('smetana')

        theme = source.attr('theme', nil)
        options[:theme] = theme if theme

        options[:debug] = true if source.opt('debug')

        options
      end

      def should_preprocess(source)
        source.attr('preprocess', 'true') == 'true'
      end

      def convert(source, format, options)
        plantuml_native = PlantUmlConverter.find_plantuml_native(source)
        if plantuml_native
          convert_native(plantuml_native, source, format, options)
        elsif PLANTUML_JARS
          convert_http(source, format, options)
        else
          raise "Could not load PlantUML. Either require 'asciidoctor-diagram-plantuml' " \
                  "or specify the location of the PlantUML JAR(s) using the 'DIAGRAM_PLANTUML_CLASSPATH' environment variable. " \
                  "Alternatively a PlantUML binary can be provided (plantuml-native in $PATH)."
        end
      end

      def add_common_headers(headers, source)
        base_dir = source.base_dir

        config_file = source.attr('plantumlconfig', nil, true) || source.attr('config')
        if config_file
          headers['X-PlantUML-Config'] = File.expand_path(config_file, base_dir)
        end

        headers['X-PlantUML-Basedir'] = Platform.native_path(File.expand_path(base_dir))

        include_dir = source.attr('includedir')
        if include_dir
          headers['X-PlantUML-IncludeDir'] = Platform.native_path(File.expand_path(include_dir, base_dir))
        end
      end

      def add_theme_header(headers, theme)
        headers['X-PlantUML-Theme'] = theme if theme
      end

      def add_size_limit_header(headers, limit)
        headers['X-PlantUML-SizeLimit'] = limit if limit
      end

      def convert_http(source, format, options)
        Java.load

        code = source.code

        case format
        when :png
          mime_type = 'image/png'
        when :svg
          mime_type = 'image/svg+xml'
        when :txt, :utxt
          mime_type = 'text/plain;charset=utf-8'
        when :atxt
          mime_type = 'text/plain'
        else
          raise "Unsupported format: #{format}"
        end

        headers = {
          'Accept' => mime_type
        }

        unless should_preprocess(source)
          add_common_headers(headers, source)
        end

        add_theme_header(headers, options[:theme])
        add_size_limit_header(headers, options[:size_limit])

        dot = source.find_command('dot', :alt_attrs => ['graphvizdot'], :raise_on_error => false)
        if options[:smetana] || !dot
          headers['X-Graphviz'] = 'smetana'
        else
          headers['X-Graphviz'] = ::Asciidoctor::Diagram::Platform.host_os_path(dot)
        end

        if options[:debug]
          headers['X-PlantUML-Debug'] = 'true'
        end

        response = Java.send_request(
          :url => '/plantuml',
          :body => code,
          :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("PlantUML image generation failed", response)
        end

        if response[:headers]['content-type'] =~ /multipart\/form-data;\s*boundary=(.*)/
          boundary = $1
          parts = {}

          multipart_data = StringIO.new(response[:body])
          while true
            multipart_data.readline
            marker = multipart_data.readline
            if marker.start_with? "--#{boundary}--"
              break
            elsif marker.start_with? "--#{boundary}"
              part = Java.parse_body(multipart_data)
              if part[:headers]['content-disposition'] =~ /form-data;\s*name="([^"]*)"/
                if $1 == 'image'
                  parts[:result] = part[:body]
                else
                  parts[:extra] ||= {}
                  parts[:extra][$1] = part[:body]
                end
              else
                raise "Unexpected multipart content disposition"
              end
            else
              raise "Unexpected multipart boundary"
            end
          end

          parts
        else
          response[:body]
        end
      end

      def add_theme_arg(args, theme)
        if theme
          args << '-theme' << theme
        end
      end

      def add_common_args(args, source)
        base_dir = File.expand_path(source.base_dir)
        args << '-filedir'
        args << base_dir

        config_file = source.attr('plantumlconfig', nil, true) || source.attr('config')
        if config_file
          args << '-config'
          args << File.expand_path(config_file, base_dir)
        end

        include_dir = source.attr('includedir')
        if include_dir
          args << "-Dplantuml.include.path=#{Platform.native_path(File.expand_path(include_dir, base_dir))}"
        end
      end

      def convert_native(plantuml, source, format, options)
        code = source.code

        args = []
        env = {}

        args << case format
        when :png
          '-tpng'
        when :svg
          '-tsvg'
        when :txt, :utxt
          '-tutxt'
        when :atxt
          '-ttxt'
        else
          raise "Unsupported format: #{format}"
        end

        add_common_args(args, source)
        add_theme_arg(args, options[:theme])

        if options[:size_limit]
          env['PLANTUML_LIMIT_SIZE'] = options[:size_limit]
        end

        dot = source.find_command('dot', :alt_attrs => ['graphvizdot'], :raise_on_error => false)
        if options[:smetana] || !dot
          args << '-Playout=smetana'
        else
          args << '-graphvizdot'
          args << ::Asciidoctor::Diagram::Platform.host_os_path(dot)
        end

        generate_stdin_stdout(plantuml, code) do |tool, _|
          cmd = [tool]
          cmd << '-pipe'
          cmd << '-failfast2'
          cmd << '-stdrpt:1'
          cmd.concat args

          {
            :args => cmd,
            :env => env
          }
        end
      end
    end

    class UmlConverter < PlantUmlConverter
      def self.tag
        'uml'
      end
    end

    class SaltConverter < PlantUmlConverter
      def self.tag
        'salt'
      end
    end

    class PlantUMLPreprocessedSource < SimpleDelegator
      include CliGenerator

      def initialize(source, converter)
        super(source)
        @converter = converter
      end

      def code
        @code ||= load_code
      end

      def load_code
        code = __getobj__.code

        tag = @converter.class.tag
        code = "@start#{tag}\n#{code}\n@end#{tag}" unless code.index("@start") && code.index("@end")

        if @converter.should_preprocess(self)
          plantuml_native = PlantUmlConverter.find_plantuml_native(self)
          if plantuml_native
            code = preprocess_native(plantuml_native, code)
          else
            code = preprocess_http(code)
          end
        end

        code
      end

      private

      def preprocess_http(code)
        Java.load

        headers = {}
        @converter.add_common_headers(headers, self)
        @converter.add_theme_header(headers, @converter.collect_options(self)[:theme])

        response = Java.send_request(
          :url => '/plantumlpreprocessor',
          :body => code,
          :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("PlantUML preprocessing failed", response)
        end

        code = response[:body]
        code.force_encoding(Encoding::UTF_8)
      end

      def preprocess_native(plantuml, code)
        generate_stdin_stdout(plantuml, code) do |tool, _|
          cmd = [tool]
          cmd << '-pipe'
          cmd << '-preproc'
          cmd << '-failfast2'
          cmd << '-stdrpt:1'

          @converter.add_common_args(cmd, self)
          @converter.add_theme_arg(cmd, @converter.collect_options(self)[:theme])

          base_dir = File.expand_path(self.base_dir)
          cmd << '-filedir'
          cmd << base_dir

          config_file = self.attr('plantumlconfig', nil, true) || self.attr('config')
          if config_file
            cmd << '-config'
            cmd <<  File.expand_path(config_file, base_dir)
          end

          include_dir = self.attr('includedir')
          if include_dir
            cmd << "-Dplantuml.include.path=#{Platform.native_path(File.expand_path(include_dir, base_dir))}"
          end

          theme = @converter.collect_options(self)[:theme]
          if theme
            cmd << '-theme' << theme
          end

          {
            :args => cmd
          }
        end
      end
    end
  end
end
