require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'yard'
require 'yard/rake/yardoc_task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end

task(default: :test)

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end
