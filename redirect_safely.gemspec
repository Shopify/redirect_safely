# coding: utf-8
#
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require './lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'redirect_safely'
  spec.version       = RedirectSafely::VERSION
  spec.authors       = ['Shopify']
  spec.email         = ['gems@shopify.com']

  spec.summary       = %q{Sanitize redirect_to URLs}
  spec.description   = %q{Sanitize redirect_to URLs}
  spec.homepage      = 'https://github.com/shopify/redirect_safely'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["source_code_uri"] = "https://github.com/shopify/redirect_safely"
  spec.metadata["changelog_uri"] = "https://github.com/shopify/redirect_safely/blob/master/CHANGELOG.md"
  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel'

  spec.add_development_dependency 'activesupport', '~>3.0'
  spec.add_development_dependency 'test-unit', '~>3.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
