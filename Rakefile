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

Rake::Task[:build].enhance ['lexer:build']
Rake::Task[:clean].enhance ['lexer:clean']

require 'yard'
YARD::Rake::YardocTask.new do |t|
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

Rake::Task[:spec].enhance ['lexer:build']

task default: :spec
