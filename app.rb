# This file contains your application, it requires dependencies and necessary
# parts of the application.
#
# It will be required from either `config.ru` or `start.rb`

require 'rubygems'
require 'ramaze'

Ramaze.setup :verbose => false do
  gem 'sequel', :version => '>=3.1.0'
  gem 'i18n',   :version => '>=0.3.0'
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

# Load the Internationalization files
I18n.load_path += Dir[ File.join(__DIR__, 'locales', '**', '*.{rb,yml}') ]
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

# Ramaze.options.each_option{|key, value| puts("%-20s: %s" % [key, value[:value]]) }

# Initialize controllers and models
require __DIR__('app/models/init')
require __DIR__('app/controllers/init')
