# Use this file directly like `ruby start.rb` if you don't want to use the
# `ramaze start` command.
# All application related things should go into `app.rb`, this file is simply
# for options related to running the application locally.

require File.join(File.expand_path(File.dirname(__FILE__)), 'app')

Ramaze.start(:adapter => :mongrel, :port => 7000, :file => __FILE__) do |mode|
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
  mode.use Rack::Localize
  mode.use Ramaze::Reloader
  mode.run Ramaze::AppMap
end
