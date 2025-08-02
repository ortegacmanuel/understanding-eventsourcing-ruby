require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'slices/**/*_test.rb'
  t.verbose = false
end

task default: :test