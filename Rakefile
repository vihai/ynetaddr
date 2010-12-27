require 'rubygems'
require 'rake'

begin
  require 'jeweler'

  Jeweler::Tasks.new do |s|
    s.name = 'netaddr'
    s.summary = 'Network addressing object'
    s.email = 'daniele@orlandi.com'
    s.homepage = 'http://www.orlandi.com/'
    s.description = 'Implements MAC address, IPv4/IPv6 addresses/networks/interfaces'
    s.authors = ['Daniele Orlandi']
    s.files = FileList['[A-Z]*.*', '{lib,spec,config,ext}/**/*', 'VERSION']
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-f progress', '-r ./spec/spec_helper.rb', '--color', '--backtrace']
end

require 'rake/rdoctask'
desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'netaddr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README', 'NOTICE')
  rdoc.rdoc_files.include('lib/netaddr.rb')
  rdoc.rdoc_files.include('lib/netaddr/**/*.rb')
end
