# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ts_eshop/version'

Gem::Specification.new do |spec|
  spec.name          = "ts_eshop"
  spec.version       = TsEshop::VERSION
  spec.authors       = ["Alexandr S"]
  spec.email         = ["alexandr@avaio-media.ru"]
  spec.summary       = %q{ECommerce for TemSys}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'template_system'
end
