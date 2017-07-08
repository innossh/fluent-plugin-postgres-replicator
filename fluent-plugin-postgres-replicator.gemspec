# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-postgres-replicator"
  gem.version       = "0.1.0"
  gem.authors       = ["innossh"]
  gem.email         = ["innossh@users.noreply.github.com"]

  gem.summary       = %q{PostgreSQL replication input plugin for Fluent}
  gem.homepage      = "https://github.com/innossh/fluent-plugin-postgres-replicator"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd", [">= 0.14.0", "< 2"]
  gem.add_runtime_dependency "pg"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
end
