require 'bundler'
require 'bundler/gem_tasks'
Bundler.require

namespace :lexer do
  desc 'Generate Lexer class'
  task :build do
    system('rex lib/scim2/filter/lexer.rex') or abort 'Failure generating lexer'
  end

  desc 'Clean Lexer class'
  task :clean do
    FileUtils.rm_f('lib/scim2/filter/lexer.rex.rb')
  end
end

namespace :parser do
  desc 'Generate Parser class'
  task :build do
    system("racc lib/scim2/filter/parser.racc") or abort 'Failure generating parser'
  end

  desc 'Clean Parser class'
  task :clean do
    FileUtils.rm_f('lib/scim2/filter/parser.tab.rb')
  end
end

Rake::Task[:build].enhance ['lexer:build', 'parser:build']
Rake::Task[:clean].enhance ['lexer:clean', 'parser:clean']

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

Rake::Task[:spec].enhance ['lexer:build', 'parser:build']

task default: :spec
