require 'rubygems/package_task'
require 'rspec/core/rake_task'

test = RSpec::Core::RakeTask.new(:test)

if ENV['APPVEYOR']
  # Exclude diagram types that require external libraries that are difficult to build on Windows.
  test.exclude_pattern = 'spec/**/{blockdiag,shaape}_spec.rb'
end

task :default => :test

spec = Gem::Specification.load('asciidoctor-diagram.gemspec')
Gem::PackageTask.new(spec) { |task| }
