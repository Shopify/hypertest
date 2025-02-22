
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "hypertest"
  spec.version       = "0.1.1"
  spec.authors       = ["Burke Libbey"]
  spec.email         = ["burke.libbey@shopify.com"]

  spec.summary       = %q{Run tests fast}
  spec.description   = %q{Run tests fast}
  spec.homepage      = "https://github.com/Shopify/hypertest"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12"

  spec.add_dependency "rb-fsevent", "~> 0.10.3"
end
