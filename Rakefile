require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'slices/**/*_test.rb'
  t.verbose = false
end

task default: :test

# Auto-import rake tasks defined inside slice folders
Dir.glob('slices/**/tasks*.rake').each { |task_file| import task_file }