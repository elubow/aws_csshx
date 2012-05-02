# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aws_csshx/version"

Gem::Specification.new do |s|
  s.name        = "aws_csshx"
  s.version     = AwsCsshx::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Russell Bradberry", "Eric Lubow"]
  s.email       = ["eric@lubow.org"]
  s.homepage    = ""
  s.summary     = %q{csshx wrapper that interacts with your AWS account for group ssh sessions}
  s.description = %q{csshx wrapper that interacts with your AWS account for group ssh sessions}

  s.add_dependency 'right_aws'

  s.rubyforge_project = "aws_csshx"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
