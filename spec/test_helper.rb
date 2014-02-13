require 'asciidoctor'
require 'asciidoctor/cli/invoker'

require 'fileutils'
require 'stringio'
require 'tmpdir'

require_relative '../lib/asciidoctor-diagram'
require_relative '../lib/asciidoctor-diagram/ditaa/extension'
require_relative '../lib/asciidoctor-diagram/plantuml/extension'

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
end

RSpec.configure do |c|
  TEST_DIR = 'testing'

  c.before(:all) do
    #FileUtils.rm_r TEST_DIR if Dir.exists? TEST_DIR
    FileUtils.mkdir_p TEST_DIR
  end

  c.around(:each) do |example|
    test_dir = Dir.mktmpdir 'test', File.expand_path(TEST_DIR)

    old_wd = Dir.pwd
    Dir.chdir test_dir
    begin
      example.run
    ensure
      Dir.chdir old_wd
    end
  end
end