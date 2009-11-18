# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rake'
require 'rake/testtask'
#require 'rake/rdoctask'

Dir["#{File.dirname(__FILE__)}/tasks/**/*.rake"].sort.each { |rake_file| load rake_file }
