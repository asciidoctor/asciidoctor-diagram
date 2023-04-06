# frozen_string_literal: true

require 'time'


spec = Gem::Specification.load Dir['*.gemspec'].first
gem_name = spec.name
gem_version = Gem::Version.create(ARGV[0])
gem_dist_url = %(https://rubygems.org/gems/#{gem_name})
release_notes_file = 'pkg/release-notes.md'
release_user = ENV['RELEASE_USER'] || 'pepijnve'
release_tag = %(v#{gem_version})
release_date = Time.at(`git log -1 --format=%ct #{release_tag}`.to_i)
previous_tag = (`git -c versionsort.suffix=. -c versionsort.suffix=- ls-remote --tags --refs --sort -v:refname origin`.each_line chomp: true)
                 .map {|it| (it.rpartition '/')[-1] }
                 .drop_while {|it| it != release_tag }
                 .reject {|it| it == release_tag }
                 .find {|it| (Gem::Version.new it.slice 1, it.length) < gem_version }
repo_url = spec.metadata['source_code_uri']
repo_url = repo_url[0..-5] if repo_url.end_with?('.git')
changelog = (File.readlines 'CHANGELOG.adoc', chomp: true, mode: 'r:UTF-8').reduce nil do |accum, line|
  if line =~ /== (\d+\.\d+\.\d+)/
    matched_version = Gem::Version.create($1)
    if matched_version == gem_version
      accum = []
    elsif matched_version < gem_version && accum
      break accum.join ?\n
    end
  elsif accum
    if line.end_with? '::'
      line = %(### #{line.slice 0, line.length - 2})
    elsif line =~ /\\s+\\*/
      line = line.lstrip
    end
    line.gsub!(/(https?:.*?)\[(.*?)\]/, '[\2](\1)')
    accum << line unless line.empty?
  end
  accum
end

release_notes = <<~EOS.chomp
## Distribution
- [RubyGem (#{gem_name})](#{gem_dist_url})
## Changelog
#{changelog}
## Release meta
Released on: #{release_date}
Released by: @#{release_user}
Logs: #{previous_tag ? %( [source diff](#{repo_url}/compare/#{previous_tag}...#{release_tag}) | [gem diff](https://my.diffend.io/gems/#{gem_name}/#{previous_tag[1..]}/#{release_tag[1..]})) : ''}
EOS

File.write release_notes_file, release_notes, mode: 'w:UTF-8'