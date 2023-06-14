require 'rspec'

require 'asciidoctor'
require 'asciidoctor/cli/invoker'

require 'fileutils'
require 'stringio'
require 'tmpdir'

require_relative '../lib/asciidoctor-diagram'
require_relative '../lib/asciidoctor-diagram/util/platform'
require_relative 'shared_examples'

module Asciidoctor
  class AbstractBlock
    def find(&block)
      blocks.each do |b|
        if block.call(b)
          return b
        end

        if (found_block = b.find(&block))
          return found_block
        end
      end
      nil
    end
  end

  class Table
    def find(&block)
      rows.by_section.each do |section, rows|
        rows.each do |row|
          row.each do |cell|
            inner_doc = cell.inner_document
            if !inner_doc.nil? && found_block = cell.inner_document.find(&block)
              return found_block
            end
          end
        end
      end
      nil
    end
  end
end

module Asciidoctor
  module Diagram
    module TestHelpers
      include ::Asciidoctor::Logging

      def load_asciidoc(source, options = {})
        options = options.dup
        options[:trace] = true
        options[:attributes] ||= {}

        options[:attributes]['phantomjs_19'] = ENV['PHANTOMJS_19']

        options[:attributes]['phantomjs_2'] = ENV['PHANTOMJS_2']

        fontpath = ENV['BLOCKDIAG_FONTPATH']
        if fontpath
          options[:attributes]['actdiag-fontpath'] = fontpath
          options[:attributes]['blockdiag-fontpath'] = fontpath
          options[:attributes]['seqdiag-fontpath'] = fontpath
          options[:attributes]['nwdiag-fontpath'] = fontpath
          options[:attributes]['rackdiag-fontpath'] = fontpath
          options[:attributes]['packetdiag-fontpath'] = fontpath
          options[:attributes]['seqdiag-fontpath'] = fontpath
        end

        unless options[:attributes]['diagram-on-error']
          options[:attributes]['diagram-on-error'] = 'abort'
        end

        logger.level = ::Logger::Severity::DEBUG
        ::Asciidoctor.load(StringIO.new(source), options.merge({:trace => true, :verbose => 2}))
      end
    end
  end
end

RSpec.configure do |c|
  c.formatter = :documentation

  c.include ::Asciidoctor::Diagram::TestHelpers

  case ::Asciidoctor::Diagram::Platform.os
    when :macosx
      c.filter_run_excluding :broken_on_osx => true
    when :windows
      c.filter_run_excluding :broken_on_windows => true
  end

  if ENV['GITHUB_ACTIONS']
    c.filter_run_excluding :broken_on_github => true
  end

  TEST_DIR = File.expand_path('testing')

  c.before(:suite) do
    FileUtils.rm_r TEST_DIR if Dir.exist? TEST_DIR
    FileUtils.mkdir_p TEST_DIR
  end

  c.around(:each) do |example|
    metadata = example.metadata
    group_dir = File.expand_path(metadata[:example_group][:full_description].gsub(/[^\w]+/, '_'), TEST_DIR)
    FileUtils.mkdir_p(group_dir) unless Dir.exist?(group_dir)

    test_dir = File.expand_path(metadata[:description].gsub(/[^\w]+/, '_'), group_dir)
    FileUtils.mkdir_p(test_dir) unless Dir.exist?(test_dir)

    Dir.chdir(test_dir) do
      example.run
    end
  end
end
