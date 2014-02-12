require 'rubygems/package_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test)

task :default => :test

['ruby', 'java'].map do |platform|
  $platform = platform
  spec = Gem::Specification.load('asciidoctor-diagrams.gemspec')
  Gem::PackageTask.new(spec) { |task| }
end