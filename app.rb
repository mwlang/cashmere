# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'

Ramaze.setup :verbose => true do
  gem 'sequel', '3.1.0'
end

# Make sure that Ramaze knows where you are
Ramaze.options.roots = [File.join(__DIR__, 'app')]
Ramaze.options.views = File.join('app', 'views')
Ramaze.options.layouts = File.join('app', 'views', 'layouts')

# Establish database connection 
DB_CONFIG = YAML.load(File.read(File.join(__DIR__, 'database.yml')))
DB = Sequel.connect(DB_CONFIG[Ramaze.options[:mode].to_s])

# Ramaze.options.each_option{|key, value| puts("%-20s: %s" % [key, value[:value]]) }

# Initialize controllers and models
require __DIR__('app/models/init')
require __DIR__('app/controllers/init')
