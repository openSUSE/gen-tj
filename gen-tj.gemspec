# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gen-tj/version"

Gem::Specification.new do |s|
  s.name        = "gen-tj"
  s.version     = GenTJ::GenTJ::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = ""
  s.summary     = %q{Generate Taskjuggler plans from Bugzilla and FATE}
  s.description = %q{Given a list of resources (developers), a
Bugzilla named query and a FATE relationtree, this tool generates a
TaskJuggler overview of current work assigned to developers.
Additionally, it checks present.suse.de for vacations and public
holidays.}

  s.add_dependency("dm-keeper-adapter", ["~> 0.0.4"])
  s.add_dependency("dm-bugzilla-adapter", ["~> 0.0.1"])
  
  s.rubyforge_project = "gen-tj"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = `git ls-files -- {samples}/*`.split("\n")
  s.require_paths = ["lib"]
end
