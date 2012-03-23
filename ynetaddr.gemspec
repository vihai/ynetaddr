# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'net/addr/version'

Gem::Specification.new do |s|
  s.name        = 'ynetaddr'
  s.version     = Net::Addr::VERSION
  s.authors     = ['Daniele Orlandi']
  s.email       = ['daniele@orlandi.com']
  s.homepage    = 'http://www.yggdra.it/'
  s.summary     = %Q{Network addressing classes}
  s.description = %Q{Network addressing classes including v4/v6 address and networks plus MAC addresses}
  s.rubyforge_project = 'ynetaddr'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # specify any dependencies here; for example:
  # s.add_development_dependency 'rspec'
end
