require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "aws_csshx"
    gem.executables = "aws_csshx"
    gem.summary = "csshx wrapper that interacts with your AWS account for group ssh sessions"
    gem.description = "csshx wrapper that interacts with your AWS account for group ssh sessions"
    gem.email = "eric@lubow.org"
    gem.homepage = "https://github.com/elubow/aws_csshx"
    gem.authors = ["Russell Bradberry", "Eric Lubow"]
    gem.add_dependency 'right_aws'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "aws_csshx #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
