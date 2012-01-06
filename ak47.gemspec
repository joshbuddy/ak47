# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ak47/version"

Gem::Specification.new do |s|
  s.name        = "ak47"
  s.version     = Ak47::VERSION
  s.authors     = ["Josh Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Reload anything}
  s.description = %q{Reload anything.}

  s.rubyforge_project = "ak47"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "guard", "~> 0.10.0"
  s.add_dependency "shell_tools", "~> 0.1.0"
  s.add_dependency "smart_colored"
end
