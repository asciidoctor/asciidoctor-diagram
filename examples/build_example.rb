require 'rubygems'
require 'bundler/setup'

require 'asciidoctor'
require 'asciidoctor/cli/options'
require 'asciidoctor/cli/invoker'
require 'asciidoctor-diagram'

Asciidoctor::Cli::Invoker.new(*ARGV).invoke!