# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require Pathname.new(__FILE__).dirname.join("lib/media_metadata_sync/version")

Gem::Specification.new do |s|
  s.name        = "media_metadata_sync"
  s.version     = MediaMetadataSync::VERSION
  s.authors     = ["Andy Hartford"]
  s.email       = ["hartforda@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rb-appscript"
  s.add_runtime_dependency "activesupport"

  s.add_development_dependency "rspec"
end
