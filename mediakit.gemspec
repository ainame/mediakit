# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mediakit/version'

Gem::Specification.new do |spec|
  spec.name          = "mediakit"
  spec.version       = Mediakit::VERSION
  spec.authors       = ["ainame"]
  spec.email         = ["s.namai.09@gmail.com"]

  spec.summary       = 'mediakit is the libraries for ffmpeg and sox backed media manipulation something.'
  spec.description   = <<EOS
mediakit is the libraries for ffmpeg and sox backed media manipulation something.
you can create complex manipulation for media as a ruby code.
EOS

  spec.homepage      = "https://github.com/ainame/mediakit"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "cocaine", "~> 0.5.7"
  spec.add_runtime_dependency "activesupport", "~> 4"
  spec.add_runtime_dependency "cool.io", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", '~> 0.10'
  spec.add_development_dependency "ruby-debug-ide", "~> 0.4"
  spec.add_development_dependency "yard", "> 0.8"
end
