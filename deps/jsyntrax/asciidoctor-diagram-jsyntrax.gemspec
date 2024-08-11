# coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'asciidoctor-diagram-jsyntrax'
  s.version       = '1.38.2'
  s.authors       = ['Ivan Ponomarev']
  s.email         = ['ivan@galahad.ee']
  s.description   = %q{JSyntrax JAR files wrapped in a Ruby gem}
  s.summary       = %q{JSyntrax JAR files wrapped in a Ruby gem}
  s.homepage      = 'https://atp-mipt.github.io/jsyntrax/'
  s.metadata      = { 'source_code_uri' => 'https://github.com/asciidoctor/asciidoctor-diagram' }
  s.license       = 'MIT'

  s.files         = Dir['**/*']
  s.require_paths = ['lib']
  s.add_runtime_dependency 'asciidoctor-diagram-batik', '~> 1.17'
end
