# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "mongo_profiler"
  spec.version       = MongoProfiler::VERSION
  spec.authors       = ["Pablo Cantero"]
  spec.email         = ["pablo@pablocantero.com"]
  spec.summary       = %q{Ruby profiling tool for MongoDB}
  spec.description   = %q{A Ruby profiling tool for MongoDB}
  spec.homepage      = "https://github.com/phstc/mongo_profiler"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "mongo", "1.9.2"
  spec.add_development_dependency "bson_ext"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "shotgun"
end
