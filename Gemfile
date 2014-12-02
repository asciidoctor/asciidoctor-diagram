if ENV.any? { |k,_| k.start_with? 'APPVEYOR' }
  # Use non-encrypted
  source 'http://rubygems.org'
else
  source 'https://rubygems.org'
end

# Specify your gem's dependencies in asciidoctor-diagram.gemspec
gemspec
