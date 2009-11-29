# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'

Ramaze.middleware :spec do |mode|
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
end

if ENV["MODE"]
  Ramaze.options.mode = ENV["MODE"].to_sym 
  puts "using #{Ramaze.options.mode.inspect} mode supplied by environment"
end

Ramaze.setup :verbose => Ramaze.options.mode == :dev do
  gem 'sequel', :version => '>=3.1.0'
  gem 'erubis', :version => '>=2.6.5'
end

# Load the library files 
Dir[File.join(__DIR__, 'lib', '*.rb')].each{|lib_file| require lib_file}

# Make sure that Ramaze knows where the good stuff is
Ramaze.options.roots = [__DIR__]
Ramaze.options.views = File.join('app', 'views')
Ramaze.options.layouts = File.join(Ramaze.options.views, 'layouts')

# Establish database connection 
DB_CONFIG = YAML.load(File.read(File.join(__DIR__, 'database.yml')))
DB = Sequel.connect(DB_CONFIG[Ramaze.options[:mode].to_s])
LOCALE_PATH = File.join(__DIR__, 'locales', '*.yaml')

COOKIE_NAME = "TGC"

# Ramaze.options.each_option{|key, value| puts("%-20s: %s" % [key, value[:value]]) }

# Initialize controllers and models
require __DIR__('app/models/init')
require __DIR__('app/controllers/init')
