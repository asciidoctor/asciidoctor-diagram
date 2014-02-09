if RUBY_PLATFORM == "java"
  require_relative 'java_jruby'
else
  require_relative 'java_rjb'
end
