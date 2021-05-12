require 'bundler'
require 'bundler/gem_tasks'
Bundler.require

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec
